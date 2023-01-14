function generateRoomId() {
  return Math.random().toString(36).substring(2, 8).toLowerCase();
}

export function startRoomListeners(socket) {
  socket.on("createRoom", (gameMode, callback) => {
    const roomId = generateRoomId();
    console.log(socket.id, "create:", roomId);
    global.rooms[roomId] = { users: new Set([socket.id]), gameMode };
    socket.join(roomId);
    callback(roomId);
  });

  socket.on("joinRoom", (roomId, callback) => {
    console.log(socket.id, "join:", roomId);
    if (!global.rooms[roomId]) {
      callback("Room does not exist");
    } else {
      global.rooms[roomId].users.add(socket.id);
      socket.join(roomId);
      io.to(roomId).emit("updateUsers", global.rooms[roomId].users.size);
      callback("Success");
    }
  });
}

export function handleDisconnect(socket) {
  socket.rooms.forEach((roomId) => {
    if (v == socket.id) return;
    global.rooms[roomId].users.delete(socket.id);
    io.to(roomId).emit("updateUsers", global.rooms[roomId].users.size);
  });
}
