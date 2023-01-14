import { GameState } from "./gamestate.js";

const CHUNK_SIZE = 3;
const NUM_KEY = 5;
const MIN_NUM_KEY = 3;

//taken from https://stackoverflow.com/questions/2450954/how-to-randomize-shuffle-a-javascript-array?page=1&tab=scoredesc#tab-top
function shuffle(array) {
  let currentIndex = array.length,
    randomIndex;
  while (currentIndex != 0) {
    randomIndex = Math.floor(Math.random() * currentIndex);
    currentIndex--;
    [array[currentIndex], array[randomIndex]] = [
      array[randomIndex],
      array[currentIndex],
    ];
  }
  return array;
}

function generateKeys(mazeSize) {
  let chunks = [];
  for (let i = 0; i < mazeSize; i += CHUNK_SIZE) {
    for (let j = 0; j < mazeSize; j += CHUNK_SIZE) {
      chunks.push([i, j]);
    }
  }
  chunks = shuffle(chunks);

  const keys = new Set();
  let found = 0;
  for (let k = 0; k < NUM_KEY + found; k++) {
    const [i, j] = chunks[k];
    const x = i + Math.floor(Math.random() * CHUNK_SIZE);
    const y = j + Math.floor(Math.random() * CHUNK_SIZE);

    if (x < mazeSize && y < mazeSize) keys.add(`${x},${y}`);
  }

  return keys;
}

function generateExit(mazeSize) {
  const topBot = Math.random() < 0.5;
  const top = Math.random() < 0.5;
  let tile;
  while (!tile || tile === mazeSize - 1)
    tile = Math.floor(Math.random() * mazeSize);

  if (topBot) {
    return [tile, top ? 0 : mazeSize];
  }
  //Assume top as left
  return [top ? 0 : mazeSize, tile];
}

function keyToCoordinates(keys) {
  return Array.from(keys).map((v) => v.split(",").map((x) => parseInt(x)));
}

function getCatcher(players) {
  return players[Math.floor(Math.random() * players.length)];
}

export class EscapeGameState extends GameState {
  constructor(roomId, mazeSize) {
    super(roomId, mazeSize);
    this.alivePlayers = {};
    this.changedAlive = false;
    this.changedKeys = false;
    this.keysFound = 0;
  }

  startGame() {
    super.startGame();

    this.catcher = getCatcher(global.rooms[this.roomId].players);
    global.rooms[this.roomId].players.forEach((socketId) => {
      if (this.catcher === socketId) return;
      this.alivePlayers[socketId] = true;
    });

    this.keys = generateKeys(this.maze.vert.length);
    this.exit = generateExit(this.maze.vert.length);

    const START_LOCATIONS = [
      [0, 0],
      [this.maze.vert.length - 1, 0],
      [0, this.maze.vert.length - 1],
      [this.maze.vert.length - 1, this.maze.vert.length - 1],
    ];
    global.io.to(this.roomId).emit("keys", {
      keysFound: this.keysFound,
      keys: keyToCoordinates(this.keys),
    });

    this.locations = Array.from(global.rooms[this.roomId].players).reduce(
      (loc, socketId, i) => {
        loc[socketId] = START_LOCATIONS[i];
        return loc;
      },
      {}
    );
  }

  updatePositions() {
    super.updatePositions();

    if (this.changedAlive) {
      const playersLeft = Object.values(this.alivePlayers).filter(
        (v) => v
      ).length;
      global.io.to(this.roomId).emit("updateLives", {
        alivePlayers: JSON.stringify(this.alivePlayers),
        playersLeft,
      });

      if (playersLeft === 0) this.endGame();
      this.changedAlive = false;
    }

    if (this.changedKeys) {
      global.io.to(this.roomId).emit("keys", {
        keysFound: this.keysFound,
        keys: keyToCoordinates(this.keys),
      });
      this.changedKeys = false;
    }
  }

  processInput(socketId, serverTicks, newInput, packetNum) {
    super.processInput(socketId, serverTicks, newInput, packetNum);

    const [x, y] = this.locations[socketId];
    if (this.keys.has(`${x},${y}`)) {
      this.keys.delete(`${x},${y}`);
      this.keysFound++;
      this.changedKeys = true;
    }

    Object.entries(this.locations).forEach(([socketId, [oppX, oppY]]) => {
      if (oppX === x && oppY === y) {
        this.alivePlayers[socketId] = false;
        this.changedAlive = true;
      }
    });
  }

  removePlayer(socketId) {
    delete this.alivePlayers[socketId];
  }
}
