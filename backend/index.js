import express from "express";
import socketIo from "socket.io";
import http from "http";
import { handleDisconnect, startRoomListeners } from "./room";

const app = express();
const server = http.createServer(app);
const io = socketIo(server);

const rooms = {};

io.on("connection", (socket) => {
  console.log(`${socket.id} connected`);

  startRoomListeners(socket, rooms);

  socket.on("disconnect", () => {
    console.log(`${socket.id} disconnected`);
    handleDisconnect(socket, rooms);
  });
});

server.listen(3000, () => {
  console.log("Server listening on port 3000");
});
