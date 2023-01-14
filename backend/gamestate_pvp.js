import { MS_PER_LOOP, GameState } from "./gamestate.js";

const CHUNK_SIZE = 3;
const SPAWN_PROBABILITY = 0.2;

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

function generateHearts(mazeSize) {
  let chunks = [];
  for (let i = 0; i < mazeSize; i += CHUNK_SIZE) {
    for (let j = 0; j < mazeSize; j += CHUNK_SIZE) {
      chunks.push([i, j]);
    }
  }
  chunks = shuffle(chunks);

  const hearts = new Set();
  for (let k = 0; k < SPAWN_PROBABILITY * chunks.length; k++) {
    const [i, j] = chunks[k];
    const x = i + Math.floor(Math.random() * CHUNK_SIZE);
    const y = j + Math.floor(Math.random() * CHUNK_SIZE);
    if (x < mazeSize && y < mazeSize) hearts.add(`${x},${y}`);
  }

  return hearts;
}

function heartsToCoordinates(hearts) {
  return Array.from(hearts).map((v) => v.split(",").map((x) => parseInt(x)));
}

const FIRST_SHRINK_MS = 30000;
const TIME_SHRINK_MS = 15000;
export class PVPGameState extends GameState {
  constructor(roomId, mazeSize) {
    super(roomId, mazeSize);
    this.lives = {};
    this.changedLives = false;
    this.changedHearts = false;
    this.cooldown = {};

    this.NEXT_TIME_SHRINK_MS = FIRST_SHRINK_MS - TIME_SHRINK_MS;
    this.incrementTimeShrink();
  }

  async incrementTimeShrink() {
    this.NEXT_TIME_SHRINK_MS += TIME_SHRINK_MS;
    this.NEXT_TIME_SHRINK_LOOP = Math.ceil(
      this.NEXT_TIME_SHRINK_MS / MS_PER_LOOP
    );
  }

  startGame() {
    super.startGame();

    global.rooms[this.roomId].players.forEach((socketId) => {
      this.lives[socketId] = 3;
      this.cooldown[socketId] = -1;
    });

    this.hearts = generateHearts(this.maze.vert.length);

    const START_LOCATIONS = [
      [0, 0],
      [this.maze.vert.length - 1, 0],
      [0, this.mazeBounds[1][1]],
      [this.mazeBounds[0][1], this.mazeBounds[1][1]],
    ];
    global.io.to(this.roomId).emit("hearts", heartsToCoordinates(this.hearts));

    this.locations = global.rooms[roomId].players.reduce((loc, socketId, i) => {
      loc[socketId] = START_LOCATIONS[i];
      return loc;
    }, {});
  }

  updatePositions() {
    super.updatePositions();

    if (this.serverTicks >= this.NEXT_TIME_SHRINK_LOOP) {
      global.io.to(this.roomId).emit("shrinkMaze", this.mazeBounds[0][1]);

      this.mazeBounds = this.mazeBounds.reduce((curr, v) => {
        curr.push([v[0] + 1, v[1] - 1]);
        return curr;
      }, []);

      this.locations.forEach((socketId, [x, y]) => {
        if (x < this.mazeBounds[0][0] || x > this.mazeBounds[0][1]) {
          this.lives[socketId] = 0;
          this.changedLives = true;
        }
        if (y < this.mazeBounds[1][0] || y > this.mazeBounds[1][1]) {
          this.lives[socketId] = 0;
          this.changedLives = true;
        }
      });
      this.incrementTimeShrink();
    }

    if (this.changedLives) {
      const playersLeft = Object.values(this.lives).filter(
        (v) => v >= 0
      ).length;
      global.io.to(this.roomId).emit("updateLives", {
        lives: this.lives,
        playersLeft,
      });
      this.changedLives = false;
    }

    if (this.changedHearts) {
      global.io
        .to(this.roomId)
        .emit("hearts", heartsToCoordinates(this.hearts));
      this.changedHearts = false;
    }
  }

  processInput(socketId, serverTicks, newInput, packetNum) {
    super.processInput(socketId, serverTicks, newInput, packetNum);

    const [x, y] = this.locations[socketId];
    if (this.hearts.has(`${x},${y}`)) {
      this.lives[socketId]++;
      this.hearts.delete(`${x},${y}`);
      this.changedLives = true;
      this.changedHearts = true;
    }

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
        this.changedLives = true;
        global.io.to(socketId).emit("hit");
      });
      this.cooldown[socketId] = this.serverTicks + COOLDOWN_LOOPS;
    }
  }

  removePlayer(socketId) {
    delete this.lives[socketId];
  }
}
