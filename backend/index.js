import express from "express";
import { Server } from "socket.io";
import http from "http";
import { handleDisconnect, startRoomListeners } from "./room.js";

const app = express();
const server = http.createServer(app);
const io = new Server(server);

app.use(express.static(__dirname + "/public"));
app.get("/", (req, res) => {
  res.sendFile(__dirname + "/index.html");
});

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
