import 'package:attention_game/colors.dart';
import 'package:attention_game/screens/gameplay.dart';
import 'package:attention_game/widgets.dart';
import 'package:flutter/material.dart';
import 'package:attention_game/game/types/gamemode.dart';

import '../gameplay/handler.dart';

// ignore: constant_identifier_names
const double DETAIL_TEXT_HEADER_SIZE = 40;
// ignore: constant_identifier_names
const double DETAIL_TEXT_VALUE_SIZE = 30;

class Lobby extends StatefulWidget {
  final GameMode gamemode;
  final String roomcode;
  final int playerCount;

  const Lobby(
      {super.key,
      required this.gamemode,
      this.roomcode = '',
      this.playerCount = 2});

  @override
  State<Lobby> createState() => _LobbyState();
}

class _LobbyState extends State<Lobby> {
  String roomcode = '';
  int playerCount = 1;

  late GameMode playerMode;

  @override
  void initState() {
    if (widget.roomcode != '') {
      roomcode = widget.roomcode;
      playerCount = widget.playerCount;
    } else {
      Handler.createRoom(gamemodeToString(widget.gamemode), (roomId) {
        if (mounted) {
          setState(() {
            roomcode = roomId;
          });
        } else {
          roomcode = roomId;
        }
      });
    }
    Handler.updatePlayerCount((count) {
      setState(() {
        playerCount = count;
      });
    });
    Handler.listenForStart(() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Gameplay(
            gamemode: widget.gamemode,
            newGamemode: playerMode,
          ),
        ),
      );
    });

    playerMode = widget.gamemode;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    void startGamePressed() {
      Handler.startGame();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Gameplay(
            gamemode: widget.gamemode,
            newGamemode: playerMode,
          ),
        ),
      );
    }

    void switchPlayerType() {
      setState(() {
        if (playerMode == GameMode.spectator) {
          playerMode = widget.gamemode;
        } else {
          playerMode = GameMode.spectator;
        }
        Handler.setSpectator(playerMode == GameMode.spectator);
      });
    }

    Widget lobbyDetails() {
      Widget detailText(String label, String value) {
        return SizedBox(
          width: 400,
          child: Column(
            children: [
              Padding(padding: const EdgeInsets.all(15), child: Text(
                label,
                style: const TextStyle(
                  fontSize: DETAIL_TEXT_HEADER_SIZE,
                  fontWeight: FontWeight.w600,
                ),
              )),
              SelectableText(
                value,
                style: const TextStyle(
                  fontSize: DETAIL_TEXT_VALUE_SIZE,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        );
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          detailText('Game Mode', gamemodeToString(widget.gamemode)),
          detailText('Room Code', roomcode),
          detailText('Players', playerCount.toString())
        ],
      );
    }

    Widget lobbyButtons() {
      return SizedBox(
        child: Column(
          children: [
            playerMode != GameMode.spectator
                ? MenuButton(
                    buttonText: 'Start Game',
                    backgroundColor: const Color(START_GAME_BUTTON_COLOR),
                    onPressed: startGamePressed,
                  )
                : const SizedBox(height: MENU_BUTTON_HEIGHT),
            const SizedBox(height: 20.0),
            MenuButton(
              buttonText:
                  playerMode != GameMode.spectator ? 'Spectate' : 'Join Game',
              backgroundColor: const Color(SPECTATE_BUTTON_COLOR),
              onPressed: switchPlayerType,
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Join as ${playerMode != GameMode.spectator ? 'Player' : 'Spectator'}',
              style: const TextStyle(fontSize: DETAIL_TEXT_HEADER_SIZE, fontWeight: FontWeight.w100),
            ),
            const SizedBox(height: 170),
            lobbyDetails(),
            const SizedBox(height: 150),
            lobbyButtons(),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}
