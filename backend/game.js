import Loop from "accurate-game-loop";
import { Maze } from "./maze.js";

const LOOP_FPS = 5;
const MAX_LATENCY_MS = 200;
const MAX_STATE_CACHE_SIZE = Math.ceil(MAX_LATENCY_MS * (1000 / LOOP_FPS));

//TODO time based event to shrink maze or end game
export class GameState {
  constructor(roomId) {
    this.roomId = roomId;
    this.stateCache = [];

    this.locations = {};
    this.packetNumbers = {};
    this.serverTicks = 0;
    this.loop = new Loop(() => this.updatePositions(), LOOP_FPS);

    this.maze = new Maze(20, 20);
  }

  startGame() {
    this.loop.start();
    global.rooms[this.roomId].users.forEach((socketId) => {
      this.packetNumbers[socketId] = -1;
      this.locations[socketId] = [0, 0];
    });
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

    const [x, y] = this.locations[socketId];
    if ((1 << 0) & newInput) {
      if (!this.maze.horiz[y][x]) this.locations[socketId][0]--;
    }
    if ((1 << 1) & newInput) {
      if (!this.maze.horiz[y][x + 1]) this.locations[socketId][0]++;
    }
    if ((1 << 2) & newInput) {
      if (!this.maze.vert[y][x]) this.locations[socketId][1]--;
    }
    if ((1 << 3) & newInput) {
      if (!this.maze.vert[y + 1][x]) this.locations[socketId][1]++;
    }

    this.packetNumbers[socketId] = packetNum;
  }

  removePlayer(socketId) {
    delete this.packetNumbers[socketId];
    delete this.locations[socketId];
  }
}

export function createGame(roomId) {
  global.gameStates[roomId] = new GameState(roomId);
}

export function startGameListeners(socket) {
  socket.on("startGame", () => {
    Array.from(socket.rooms).forEach((roomId) => {
      if (roomId === socket.id) return;
      global.gameStates[roomId].startGame();
      const maze = global.gameStates[roomId].maze;
      global.io.to(roomId).emit("maze", [maze.horiz, maze.vert]);
    });
  });

  socket.on("playerInput", ({ packetNumber, serverTicks, input }) => {
    Array.from(socket.rooms).forEach((roomId) => {
      if (roomId === socket.id) return;
      global.gameStates[roomId].processInput(
        socket.id,
        serverTicks,
        input,
        packetNumber
      );
    });
  });
}
