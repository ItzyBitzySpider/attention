import { GameState } from "./gamestate.js";

export class EscapeGameState extends GameState {
  constructor(roomId, mazeSize) {
    super(roomId, mazeSize);
  }
}
