var socket = io();

const INPUT_MAP = ["ArrowLeft", "ArrowRight", "ArrowUp", "ArrowDown"];

class Network {
  constructor(roomId, updateUI) {
    this.roomId = roomId;
    this.updateUI = updateUI;
    this.socket = socket;
    this.packetsSent = 0;
    this.packetCache = [];
    this.serverTicks = 0;

    this.locations = {};

    this.socket.on("connected", () => console.log("Connected to server"));
    this.socket.on(
      "playerLocations",
      ({ packetNumber, serverTicks, locations }) => {
        console.log(packetNumber, serverTicks, locations);

        this.packetCache = this.packetCache.filter(
          (v) => v.packetNumber > packetNumber
        );

        this.serverTicks = serverTicks;

        //Sync with server and update inputs
        this.locations = locations;
        this.packetCache.forEach((packet) =>
          this.applyPacket(this.locations, packet.input)
        );
        this.updateUI(this.locations);
      }
    );
  }

  applyPacket(locations, input) {
    //TODO maze collision recognition
    if ((1 << 0) & input) {
      locations[this.socket.id][0]--;
    }
    if ((1 << 1) & input) {
      locations[this.socket.id][0]++;
    }
    if ((1 << 2) & input) {
      locations[this.socket.id][1]--;
    }
    if ((1 << 3) & input) {
      locations[this.socket.id][1]++;
    }
  }

  sendInput(strCode) {
    const packet = {
      packetNumber: this.packetsSent,
      serverTicks: this.serverTicks,
      input: 1 << INPUT_MAP.indexOf(strCode),
    };
    this.packetCache.push(packet);

    // !The following line artificially adds lag
    // setTimeout(() => this.socket.emit("playerInput", packet), 500);
    this.socket.emit("playerInput", packet);

    this.packetsSent++;

    this.applyPacket(this.locations, packet.input);
    this.updateUI(this.locations);
  }

  ping(callback) {
    const startTime = Date.now();
    const timestamp = startTime;
    this.socket.emit("ping", { timestamp }, (ackData) => {
      if (ackData.timestamp === timestamp) {
        const endTime = Date.now();
        const pingTime = endTime - startTime;

        callback(pingTime);
      } else {
        console.log("Timestamps do not match");
      }
    });
  }

  joinRoom() {
    this.socket.emit("joinRoom", this.roomId, (ret) => {
      console.log("JoinRoom:", ret);
    });
  }

  start() {
    this.socket.emit("startGame", this.roomId, ([horiz, vert]) => {
      console.log("Maze", horiz, vert);
    });
  }
}

function updateOtherPlayers(locations) {
  Object.entries(locations).forEach(([socketId, loc]) => {
    if (socketId == socket.id) {
      console.log(socketId, socket.id);
      return;
    }
    if (!document.getElementById(socketId)) {
      let newBox = document.createElement("div");
      newBox.id = socketId;
      document.getElementById("body").appendChild(newBox);
      newBox.style.position = "fixed";
      newBox.style.top = "50px";
      newBox.style.backgroundColor = "blue";
      newBox.style.width = "50px";
      newBox.style.height = "50px";
    }
    document.getElementById(socketId).style.left = `${50 + loc[0]}px`;
    document.getElementById(socketId).style.top = `${50 + loc[1]}px`;
  });
}

var box = document.getElementById("box");
const network = new Network("INSERT_ROOM_ID", (locations) => {
  box.style.left = `${50 + locations[this.socket.id][0]}px`;
  box.style.top = `${50 + locations[this.socket.id][1]}px`;
  updateOtherPlayers(locations);
});

network.joinRoom();

var ping = document.getElementById("ping");
setInterval(() => {
  network.ping((pingTime) => (ping.textContent = `Ping time: ${pingTime}ms`));
}, 1000);

document.addEventListener("keydown", (event) => {
  if (event.repeat) return;
  if (INPUT_MAP.includes(event.code)) network.sendInput(event.code);
});

document.getElementById("start").addEventListener("click", () => {
  network.start();
});
