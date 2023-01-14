import { GameState } from "./game.js";

global.rooms = { INSERT_ROOM_ID: new Set() };
global.gameStates = { INSERT_ROOM_ID: new GameState("INSERT_ROOM_ID") };
/*
Globals not defined in this file:
- io: Socket.io server
*/
