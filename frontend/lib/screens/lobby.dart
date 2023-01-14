import 'package:attention_game/colors.dart';
import 'package:attention_game/screens/gameplay.dart';
import 'package:attention_game/widgets.dart';
import 'package:flutter/material.dart';
import 'package:attention_game/game/common.dart';

// ignore: constant_identifier_names
const double DETAIL_TEXT_HEADER_SIZE = 40;
// ignore: constant_identifier_names
const double DETAIL_TEXT_VALUE_SIZE = 30;

class Lobby extends StatefulWidget {
  final GameMode gamemode;

  const Lobby({super.key, required this.gamemode});

  @override
  State<Lobby> createState() => _LobbyState();
}

class _LobbyState extends State<Lobby> {
  PlayerType playerType = PlayerType.player;
  String roomcode = '123 123';
  int playerCount = 6;

  @override
  Widget build(BuildContext context) {
    void startGamePressed() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Gameplay(gamemode: widget.gamemode),
        ),
      );
    }

    void switchPlayerType() {
      setState(() {
        if (playerType == PlayerType.player) {
          playerType = PlayerType.spectator;
        } else {
          playerType = PlayerType.player;
        }
      });
    }

    Widget lobbyDetails() {
      Widget detailText(String label, String value) {
        return SizedBox(
          width: 300,
          child: Column(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: DETAIL_TEXT_HEADER_SIZE,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
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
          detailText('Players', playerCount.toString()),
        ],
      );
    }

    Widget lobbyButtons() {
      return SizedBox(
        child: Column(
          children: [
            playerType == PlayerType.player
                ? MenuButton(
                    buttonText: 'Start Game',
                    backgroundColor: const Color(START_GAME_BUTTON_COLOR),
                    onPressed: startGamePressed,
                  )
                : const SizedBox(height: MENU_BUTTON_HEIGHT),
            const SizedBox(height: 20.0),
            MenuButton(
              buttonText:
                  playerType == PlayerType.player ? 'Spectate' : 'Join Game',
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
              'You are a ${playerType == PlayerType.player ? 'Player' : 'Spectator'}',
              style: const TextStyle(fontSize: DETAIL_TEXT_HEADER_SIZE),
            ),
            const SizedBox(height: 80),
            lobbyDetails(),
            const SizedBox(height: 80),
            lobbyButtons(),
          ],
        ),
      ),
    );
  }
}