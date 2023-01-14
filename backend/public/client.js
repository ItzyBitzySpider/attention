var socket = io();

var ping = document.getElementById("ping");
setInterval(() => {
  network.ping((pingTime) => (ping.textContent = `Ping time: ${pingTime}ms`));
}, 1000);
