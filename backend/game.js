export function startGameListeners(socket) {
  socket.on("startGame", () => {
    const arr = Array.from(socket.rooms);
    for (const roomId of arr) {
      if (roomId === socket.id) continue;

      if (global.rooms[roomId].gameMode === "PVP")
        global.gameStates[roomId] = new PVPGameState(roomId, 21);
      else global.gameStates[roomId] = new EscapeGameState(roomId, 21);

      global.gameStates[roomId].startGame();
      const maze = global.gameStates[roomId].maze;
      global.io.to(roomId).emit("maze", [maze.horiz, maze.vert]);
      return;
    }
  });

  socket.on("playerInput", ({ packetNumber, serverTicks, input }) => {
    const arr = Array.from(socket.rooms);
    for (const roomId of arr) {
      if (roomId === socket.id) continue;
      global.gameStates[roomId].processInput(
        socket.id,
        serverTicks,
        input,
        packetNumber
      );
      return;
    }
  });
}
