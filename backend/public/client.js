var socket = io();

var ping = document.getElementById("ping");
setInterval(() => {
  const startTime = Date.now();
  const timestamp = startTime;
  console.log("Trying");
  this.socket.emit("ping", { timestamp }, (ackData) => {
    console.log("Pinged");
    if (ackData.timestamp === timestamp) {
      const endTime = Date.now();
      const pingTime = endTime - startTime;
      ping.textContent = `Ping time: ${pingTime}ms`;
    } else {
      console.log("Timestamps do not match");
    }
  });
}, 1000);
