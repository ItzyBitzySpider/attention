import Loop from "accurate-game-loop";

const LOOP_FPS = 5;

class GameState {
  constructor(roomId) {
    this.roomId = roomId;
    this.stateCache = {}; //TODO use this to store past and handle clicks

    this.locations = {};
    this.packetNumbers = {};
    this.serverTicks = 0;
    this.loop = new Loop(() => this.updatePositions(), LOOP_FPS);
  }

  startGame() {
    this.loop.start();
    global.rooms[this.roomId].forEach((socketId) => {
      this.packetNumbers[socketId] = -1;
      this.locations[socketId] = 0;
    });
  }

  updatePositions() {
    this.serverTicks++;
    // console.log(socketId, packetNum, {
    //   packetNumber: packetNum,
    //   serverTicks: this.serverTicks,
    //   locations: this.locations,
    // });
    global.io.to(this.roomId).emit("playerLocations", {
      packetNumber: packetNum,
      serverTicks: this.serverTicks,
      locations: this.locations,
    });
  }

  processInput(socketId, serverTicks, newInput, packetNum) {
    if ((1 << 0) & newInput) {
      this.locations[socketId] -= 50;
    }
    if ((1 << 1) & newInput) {
      this.locations[socketId] += 50;
    }

    this.packetNumbers[socketId] = packetNum;
  }

  removePlayer(socketId) {
    delete this.packetNumbers[socketId];
    delete this.locations[socketId];
  }
}

export function createGame(roomId) {
  global.gameStates[roomId] = new GameState();
}

export function startGameListeners(socket) {
  socket.on("startGame", (roomId, callback) => {
    global.gameStates[roomId].startGame();
  });
}
