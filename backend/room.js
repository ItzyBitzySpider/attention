function generateRoomId() {
  return Math.random().toString(36).substring(2, 8).toLowerCase();
}

export function startRoomListeners(socket, rooms) {
  socket.on("createRoom", ({ roomId, gameMode }, callback) => {
    const roomId = generateRoomId();
    rooms[roomId] = { users: new Set([socket.id]), gameMode };
    socket.join(roomId);
    callback(roomId);
  });

  socket.on("joinRoom", (roomId, callback) => {
    if (!rooms[roomId]) {
      callback("Room does not exist");
    } else {
      rooms[roomId] = socket.handshake.query.username;
      socket.join(roomId);
      io.to(roomId).emit("updateUsers", Array.from(rooms[roomId]));
      callback("Success");
    }
  });

  socket.on("sendMessage", (roomId, message) => {
    if (!rooms[roomId]) {
      socket.emit("roomDoesNotExist", roomId);
    } else {
      io.to(roomId).emit("receiveMessage", message);
    }
  });
}

export function handleDisconnect(socket, rooms) {
  socket.rooms.forEach((roomId) => {
    if (v == socket.id) return;
    rooms[roomId].remove(socket.id);
    io.to(roomId).emit("updateUsers", Array.from(rooms[roomId]));
  });
}
