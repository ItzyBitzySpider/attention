import { GameState } from "./gamestate.js";

global.rooms = {
  INSERT_ROOM_ID: { users: new Set(), gameMode: "test", spectators: new Set() },
};
global.gameStates = { INSERT_ROOM_ID: new GameState("INSERT_ROOM_ID", 21) };
/*
Globals not defined in this file:
- io: Socket.io server
*/
