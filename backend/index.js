import express from "express";
import { Server } from "socket.io";
import http from "http";
import path from "path";
import { handleDisconnect, startRoomListeners } from "./room.js";
const __dirname = path.resolve();

const app = express();
const server = http.createServer(app);
const io = new Server(server);

app.use(express.static(__dirname + "/public"));
app.get("/", (req, res) => {
  res.sendFile(__dirname + "/index.html");
});

io.on("connection", (socket) => {
  console.log(`${socket.id} connected`);

  startRoomListeners(socket);

  socket.on("ping", (data, ack) => {
    const startTime = Date.now();
    ack({ data: "pong", timestamp: data.timestamp });
    const endTime = Date.now();
    const processingTime = endTime - startTime;
    // console.log(`Ping processing time: ${processingTime}ms`);
  });

  socket.on("disconnect", () => {
    console.log(`${socket.id} disconnected`);
    handleDisconnect(socket);
  });
});

server.listen(3000, () => {
  console.log("Server listening on port 3000");
});
