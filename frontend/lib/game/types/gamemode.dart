enum GameMode { pvp, escape, spectator, none }

String gamemodeToString(GameMode gamemode) {
  if (gamemode == GameMode.pvp) {
    return 'PVP';
  } else if (gamemode == GameMode.escape) {
    return 'Escape';
  } else if (gamemode == GameMode.spectator) {
    return 'Spectator';
  } else {
    return 'none';
  }
}
