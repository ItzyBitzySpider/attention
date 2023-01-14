import Loop from "accurate-game-loop";

const LOOP_FPS = 5;

export class GameState {
  constructor(roomId) {
    this.roomId = roomId;
    this.stateCache = {}; //TODO use this to store past and handle clicks

    this.locations = {};
    this.packetNumbers = {};
    this.serverTicks = 0;
    this.loop = new Loop(() => this.updatePositions(), LOOP_FPS);

    //TODO get start locations and map
  }

  startGame() {
    this.loop.start();
    global.rooms[this.roomId].forEach((socketId) => {
      this.packetNumbers[socketId] = -1;
      this.locations[socketId] = [0, 0];
    });
  }

  updatePositions() {
    this.serverTicks++;
    for (const [socketId, packetNum] of Object.entries(this.packetNumbers)) {
      // console.log(socketId, packetNum, {
      //   packetNumber: packetNum,
      //   serverTicks: this.serverTicks,
      //   locations: this.locations,
      // });
      global.io.to(socketId).emit("playerLocations", {
        packetNumber: packetNum,
        serverTicks: this.serverTicks,
        locations: this.locations,
      });
    }
  }

  processInput(socketId, serverTicks, newInput, packetNum) {
    if ((1 << 0) & newInput) {
      this.locations[socketId][0] -= 50;
    }
    if ((1 << 1) & newInput) {
      this.locations[socketId][0] += 50;
    }
    if ((1 << 2) & newInput) {
      this.locations[socketId][1] -= 50;
    }
    if ((1 << 3) & newInput) {
      this.locations[socketId][1] += 50;
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
  socket.on("startGame", (callback) => {
    Array.from(socket.rooms).forEach((roomId) => {
      if (roomId === socket.id) return;
      global.gameStates[roomId].startGame();
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
