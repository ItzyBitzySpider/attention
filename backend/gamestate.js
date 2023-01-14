import Loop from "accurate-game-loop";
import { Maze } from "./maze.js";

//TODO increase this lol
export const LOOP_FPS = 5;
const MAX_LATENCY_MS = 200;

const ACTION_COOLDOWN_MS = 1000;

//Derived Values
const MS_PER_LOOP = 1000 / LOOP_FPS;
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

    this.maze = new Maze(
      [mazeSize, mazeSize - 2, mazeSize - 4, mazeSize - 6, mazeSize - 8],
      0.3
    );
    this.mazeBounds = [
      [0, mazeSize - 1],
      [0, mazeSize - 1],
    ]; //Inclusive
  }

  startGame() {
    global.rooms[this.roomId].players.forEach((socketId) => {
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
