import "./globals.js";
import express from "express";
import { Server } from "socket.io";
import http from "http";
import path from "path";
import { handleDisconnect, startRoomListeners } from "./room.js";
import { startGameListeners } from "./game.js";
const __dirname = path.resolve();

const app = express();
const server = http.createServer(app);
global.io = new Server(server);

app.use(express.static(__dirname + "/public"));
app.get("/", (req, res) => {
  res.sendFile(__dirname + "/index.html");
});

global.io.on("connection", (socket) => {
  console.log(`${socket.id} connected`);

  startRoomListeners(socket);
  startGameListeners(socket);

  socket.on("ping", (data, ack) => {
    const startTime = Date.now();
    ack({ data: "pong", timestamp: data.timestamp });
    const endTime = Date.now();
    const processingTime = endTime - startTime;
    // console.log(`Ping processing time: ${processingTime}ms`);
  });

  socket.on("disconnecting", () => {
    console.log(`${socket.id} disconnecting`);
    handleDisconnect(socket);
  });

  socket.on("disconnected", () => {
    console.log(`${socket.id} disconnected`);
  });
});

server.listen(3000, () => {
  console.log("Server listening on port 3000");
});
