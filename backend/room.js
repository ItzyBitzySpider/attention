function generateRoomId() {
  return Math.random().toString(36).substring(2, 8).toLowerCase();
}

export function startRoomListeners(socket) {
  socket.on("createRoom", (gameMode, callback) => {
    const roomId = generateRoomId();
    console.log(socket.id, "create:", roomId);
    global.rooms[roomId] = {
      players: new Set([socket.id]),
      gameMode,
      spectators: new Set(),
    };
    socket.join(roomId);
    callback(roomId);
  });

  socket.on("joinRoom", (roomId, callback) => {
    console.log(socket.id, "join:", roomId);
    if (!global.rooms[roomId]) return;

    global.rooms[roomId].players.add(socket.id);
    socket.join(roomId);
    io.to(roomId).emit("updateUsers", global.rooms[roomId].players.size);
    callback({
      gameMode: global.rooms[roomId].gameMode,
      numPlayers: global.rooms[roomId].players.size,
    });
  });

  socket.on("setSpectator", (isSpectator) => {
    if (isSpectator) {
      global.rooms[roomId].players.delete(socket.id);
      global.rooms[roomId].spectators.add(socket.id);
    } else {
      global.rooms[roomId].spectators.delete(socket.id);
      global.rooms[roomId].players.add(socket.id);
    }
    io.to(roomId).emit("updateUsers", global.rooms[roomId].players.size);
  });
}

export function handleDisconnect(socket) {
  socket.rooms.forEach((roomId) => {
    if (roomId === socket.id) return;
    global.rooms[roomId].players.delete(socket.id);
    global.rooms[roomId].spectators.delete(socket.id);
    io.to(roomId).emit("updateUsers", global.rooms[roomId].players.size);
  });
}
