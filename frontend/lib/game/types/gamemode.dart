enum GameMode { pvp, escape, none }

String gamemodeToString(GameMode gamemode) {
  if (gamemode == GameMode.pvp) {
    return 'PVP';
  } else if (gamemode == GameMode.escape) {
    return 'Escape';
  } else {
    return 'none';
  }
}
