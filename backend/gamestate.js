import Loop from "accurate-game-loop";
import { Maze } from "./maze.js";

const LOOP_FPS = 60;
const MAX_LATENCY_MS = 1000;

const ACTION_COOLDOWN_MS = 450;

//Derived Values
export const MS_PER_LOOP = 1000 / LOOP_FPS;
const MAX_STATE_CACHE_SIZE = Math.ceil(MAX_LATENCY_MS / MS_PER_LOOP);
export const COOLDOWN_LOOPS = Math.ceil(ACTION_COOLDOWN_MS / MS_PER_LOOP);

export class GameState {
  constructor(roomId, mazeSize) {
    this.roomId = roomId;
    this.stateCache = [];

    this.locations = {};
    this.packetNumbers = {};
    this.serverTicks = 0;
    this.loop = new Loop(() => this.updatePositions(), LOOP_FPS);

    this.shrinkValue = 0;

    this.maze = new Maze(
      [
        mazeSize,
        mazeSize - 2,
        mazeSize - 4,
        mazeSize - 6,
        mazeSize - 8,
        mazeSize - 10,
        mazeSize - 12,
        mazeSize - 14,
      ],
      0.15
    );
  }

  startGame() {
    global.rooms[this.roomId].players.forEach((socketId) => {
      this.packetNumbers[socketId] = -1;
      this.locations[socketId] = [0, 0];
    });
    this.loop.start();
  }

  preUpdatePosition() {
    this.serverTicks++;
    return {
      serverTicks: this.serverTicks,
      locations: JSON.parse(JSON.stringify(this.locations)),
    };
  }

  postUpdatePosition(currentState) {
    for (const [socketId, packetNum] of Object.entries(this.packetNumbers)) {
      const tmpState = {
        packetNumber: packetNum,
        ...currentState,
      };
      tmpState.locations = JSON.stringify(tmpState.locations);
      // console.log(socketId, packetNum, tmpState);
      global.io.to(socketId).emit("playerLocations", tmpState);
    }
    this.stateCache.push(JSON.parse(JSON.stringify(currentState)));

    currentState.locations = JSON.stringify(currentState.locations);
    global.io.to(this.roomId).emit("playerLocationsSpectator", currentState);
    if (this.stateCache.length > MAX_STATE_CACHE_SIZE) this.stateCache.shift();
  }

  updatePositions() {
    const currentState = this.preUpdatePosition();
    this.postUpdatePosition(currentState);
  }

  processInput(socketId, serverTicks, newInput, packetNum) {
    const [x, y] = this.locations[socketId];
    if ((1 << 0) & newInput) {
      if (!this.maze.vert[y][x] && x > this.shrinkValue)
        this.locations[socketId][0]--;
    }
    if ((1 << 1) & newInput) {
      if (
        !this.maze.vert[y][x + 1] &&
        x < this.maze.vert.length - 2 - this.shrinkValue
      )
        this.locations[socketId][0]++;
    }
    if ((1 << 2) & newInput) {
      if (!this.maze.horiz[y][x] && y > this.shrinkValue)
        this.locations[socketId][1]--;
    }
    if ((1 << 3) & newInput) {
      if (
        !this.maze.horiz[y + 1][x] &&
        y < this.maze.vert.length - 2 - this.shrinkValue
      )
        this.locations[socketId][1]++;
    }
    this.packetNumbers[socketId] = packetNum;
  }

  endGame() {
    this.loop.stop();
    global.io.to(this.roomId).emit("gameEnd");
    delete global.gameStates[this.roomId];
  }

  removePlayer(socketId) {
    delete this.packetNumbers[socketId];
    delete this.locations[socketId];
  }
}
