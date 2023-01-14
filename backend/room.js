function generateRoomId() {
  return Math.random().toString(36).substring(2, 8).toLowerCase();
}

export function startRoomListeners(socket, rooms) {
  socket.on("createRoom", (gameMode, callback) => {
    const roomId = generateRoomId();
    rooms[roomId] = { users: new Set([socket.id]), gameMode };
    socket.join(roomId);
    callback(roomId);
  });

  socket.on("joinRoom", (roomId, callback) => {
    if (!rooms[roomId]) {
      callback("Room does not exist");
    } else {
      rooms[roomId].add(socket.id);
      socket.join(roomId);
      io.to(roomId).emit("updateUsers", Array.from(rooms[roomId]));
      callback("Success");
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
