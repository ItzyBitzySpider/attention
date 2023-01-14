enum GameMode { pvp, escape }

String gamemodeToString(GameMode gamemode) {
  if (gamemode == GameMode.pvp) {
    return 'PVP';
  }
  return 'Escape';
}

enum PlayerType { player, spectator }
