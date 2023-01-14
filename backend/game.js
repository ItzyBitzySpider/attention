import Loop from "accurate-game-loop";
import { Maze } from "./maze.js";

const LOOP_FPS = 5;
const MAX_LATENCY_MS = 200;

const ACTION_COOLDOWN_MS = 1000;

//Derived Values
const MS_PER_LOOP = 1000 / LOOP_FPS;
const MAX_STATE_CACHE_SIZE = Math.ceil(MAX_LATENCY_MS / MS_PER_LOOP);
const COOLDOWN_LOOPS = Math.ceil(ACTION_COOLDOWN_MS / MS_PER_LOOP);

//TODO time based event to shrink maze or end game
export class GameState {
  constructor(roomId, mazeSize) {
    this.roomId = roomId;
    this.stateCache = [];

    this.locations = {};
    this.packetNumbers = {};
    this.serverTicks = 0;
    this.loop = new Loop(() => this.updatePositions(), LOOP_FPS);

    this.maze = new Maze(mazeSize, mazeSize);
    this.mazeBounds = [
      [0, mazeSize - 1],
      [0, mazeSize - 1],
    ]; //Inclusive
    this.maze.generate();
  }

  startGame() {
    global.rooms[this.roomId].users.forEach((socketId) => {
      this.packetNumbers[socketId] = -1;
      this.locations[socketId] = [0, 0];
    });
    this.loop.start();
  }

  updatePositions() {
    this.serverTicks++;
    const currentState = {
      serverTicks: this.serverTicks,
      locations: this.locations,
    };
    for (const [socketId, packetNum] of Object.entries(this.packetNumbers)) {
      const tmpState = {
        packetNumber: packetNum,
        ...currentState,
      };
      console.log(socketId, packetNum, tmpState);
      global.io.to(socketId).emit("playerLocations", tmpState);
    }
    this.stateCache.push(currentState);
    if (this.stateCache.length > MAX_STATE_CACHE_SIZE) this.stateCache.shift();
  }

  processInput(socketId, serverTicks, newInput, packetNum) {
    const [x, y] = this.locations[socketId];
    if ((1 << 0) & newInput) {
      if (!this.maze.horiz[y][x] && x > this.mazeBounds[0][0])
        this.locations[socketId][0]--;
    }
    if ((1 << 1) & newInput) {
      if (!this.maze.horiz[y][x + 1] && x < this.mazeBounds[0][1])
        this.locations[socketId][0]++;
    }
    if ((1 << 2) & newInput) {
      if (!this.maze.vert[y][x] && y > this.mazeBounds[1][0])
        this.locations[socketId][1]--;
    }
    if ((1 << 3) & newInput) {
      if (!this.maze.vert[y + 1][x] && y < this.mazeBounds[1][1])
        this.locations[socketId][1]++;
    }

    this.packetNumbers[socketId] = packetNum;
  }

  removePlayer(socketId) {
    delete this.packetNumbers[socketId];
    delete this.locations[socketId];
  }
}

const TIME_SHRINK_MS = 30000; //in ms

class PVPGameState extends GameState {
  constructor(roomId, mazeSize) {
    super(roomId, mazeSize);
    this.lives = {};
    this.cooldown = {};

    this.NEXT_TIME_SHRINK_MS = 0;
    this.incrementTimeShrink();
  }

  async incrementTimeShrink() {
    this.NEXT_TIME_SHRINK_MS += TIME_SHRINK_MS;
    this.NEXT_TIME_SHRINK_LOOP = Math.ceil(
      this.NEXT_TIME_SHRINK_MS / MS_PER_LOOP
    );
  }

  startGame() {
    global.rooms[this.roomId].users.forEach((socketId) => {
      this.lives[socketId] = 3;
      this.cooldown[socketId] = -1;
    });
    super.startGame();
  }

  updatePositions() {
    super.updatePositions();
    const playersLeft = Object.values(this.lives).filter((v) => v >= 0).length;

    if (this.serverTicks >= this.NEXT_TIME_SHRINK_LOOP) {
      global.io.to(this.roomId).emit("shrinkMaze", this.mazeBounds[0][1]);

      this.mazeBounds = this.mazeBounds.reduce((curr, v) => {
        curr.push([v[0] + 1, v[1] - 1]);
        return curr;
      }, []);

      this.locations.forEach((socketId, [x, y]) => {
        if (x < this.mazeBounds[0][0] || x > this.mazeBounds[0][1])
          this.lives[socketId] = 0;
        if (y < this.mazeBounds[1][0] || y > this.mazeBounds[1][1])
          this.lives[socketId] = 0;
      });
      this.incrementTimeShrink();
    }

    for (const [socketId, lives] of Object.entries(this.lives)) {
      global.io.to(socketId).emit("updateLives", {
        lives,
        playersLeft,
      });
    }
  }

  processInput(socketId, serverTicks, newInput, packetNum) {
    super.processInput(socketId, serverTicks, newInput, packetNum);

    //Void input if latency from client too high
    if (this.stateCache[0] && serverTicks < this.stateCache[0].serverTicks) {
      console.warn(
        "Rejected",
        socketId,
        serverTicks,
        this.stateCache[0].serverTicks,
        packetNum
      );
      return;
    }

    //Space bar action
    if ((1 << 4) & newInput) {
      //Cooldown handling
      if (serverTicks < this.cooldown[socketId]) return;

      const locations = this.stateCache.filter(
        (v) => v.serverTicks === serverTicks
      )[0];

      const [x, y] = locations[socketId];
      Object.entries(locations).forEach((oppSocketId, [oppX, oppY]) => {
        if (oppSocketId === socketId) return;
        if (Math.abs(x - oppX) > 1) return;
        if (Math.abs(y - oppY) > 1) return;

        this.lives[oppSocketId]--;
        this.cooldown[socketId] = this.serverTicks + COOLDOWN_LOOPS;
      });
    }
  }

  removePlayer(socketId) {
    delete this.lives[socketId];
  }
}

class EscapeGameState extends GameState {
  constructor(roomId, mazeSize) {
    super(roomId, mazeSize);
  }
}

export function startGameListeners(socket) {
  socket.on("startGame", () => {
    const arr = Array.from(socket.rooms);
    for (const roomId of arr) {
      if (roomId === socket.id) continue;

      if (global.rooms[roomId].gameMode === "PVP")
        global.gameStates[roomId] = new PVPGameState(roomId, 20);
      else global.gameStates[roomId] = new EscapeGameState(roomId, 20);

      global.gameStates[roomId].startGame();
      const maze = global.gameStates[roomId].maze;
      global.io.to(roomId).emit("maze", [maze.horiz, maze.vert]);
      return;
    }
  });

  socket.on("playerInput", ({ packetNumber, serverTicks, input }) => {
    const arr = Array.from(socket.rooms);
    for (const roomId of arr) {
      if (roomId === socket.id) continue;
      global.gameStates[roomId].processInput(
        socket.id,
        serverTicks,
        input,
        packetNumber
      );
      return;
    }
  });
}
