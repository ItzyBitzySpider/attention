import 'package:attention_game/colors.dart';
import 'package:attention_game/game/types/gamemode.dart';
import 'package:attention_game/game/types/join_room_Result.dart';
import 'package:attention_game/gameplay/handler.dart';
import 'package:attention_game/screens/lobby.dart';
import 'package:attention_game/widgets.dart';
import 'package:flutter/material.dart';

class JoinGameButton extends StatefulWidget {
  const JoinGameButton({super.key});

  @override
  State<JoinGameButton> createState() => _JoinGameButtonState();
}

class _JoinGameButtonState extends State<JoinGameButton> {
  bool selected = false;
  String? roomCode;

  void _enterButtonPressed() {
    Handler.joinRoom(roomCode, (game, playerCount) {
      if (game != '') {
        // print(game);
        GameMode gm = game == 'PVP' ? GameMode.pvp : GameMode.escape;
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Lobby(
                  gamemode: gm, roomcode: roomCode!, playerCount: playerCount),
            ));
      } else {
        print("Failed");
        // TODO error handling
      }
    });
  }

  Widget joinGameButton() {
    return MenuButton(
      buttonText: 'Join Game',
      backgroundColor: const Color(JOIN_GAME_BUTTON_COLOR),
      onPressed: () => setState(() => selected = true),
    );
  }

  Widget roomCodeWidget() {
    InputBorder textfieldBorder = OutlineInputBorder(
      borderSide: const BorderSide(
        color: Color(0xFF808080),
        width: 3.0,
      ),
      borderRadius: BorderRadius.circular(10.0),
    );

    Widget roomCodeTextField = Expanded(
      child: Material(
        color: const Color(BACKGROUND_COLOR),
        borderRadius: BorderRadius.circular(10.0),
        elevation: 5.0,
        child: TextField(
          cursorColor: const Color(0xff808080),
          style: const TextStyle(height: 1.5, fontSize: 18),
          onChanged: (text) => roomCode = text,
          decoration: InputDecoration(
            focusedBorder: textfieldBorder,
            enabledBorder: textfieldBorder,
            hintText: 'Room Code',
          ),
        ),
      ),
    );

    Widget enterButton = AspectRatio(
      aspectRatio: 1,
      child: ElevatedButton(
        onPressed: _enterButtonPressed,
        style: ElevatedButton.styleFrom(
          elevation: 5.0,
          backgroundColor: const Color(JOIN_GAME_BUTTON_COLOR),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        child: const Icon(Icons.login),
      ),
    );

    return SizedBox(
      width: MENU_BUTTON_WIDTH,
      height: MENU_BUTTON_HEIGHT,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          roomCodeTextField,
          const SizedBox(width: 7),
          enterButton,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return selected ? roomCodeWidget() : joinGameButton();
  }
}

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  bool newGameSelected = false;

  Widget newGameButton() {
    return MenuButton(
      buttonText: 'New Game',
      backgroundColor: const Color(NEW_GAME_BUTTON_COLOR),
      onPressed: () => setState(() => newGameSelected = true),
    );
  }

  Widget pvpGamemodeButton() {
    return MenuButton(
      buttonText: 'PVP',
      backgroundColor: const Color(PVP_BUTTON_COLOR),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Lobby(gamemode: GameMode.pvp),
        ),
      ),
    );
  }

  Widget escapeGamemodeButton() {
    return MenuButton(
      buttonText: 'Escape',
      backgroundColor: const Color(ESCAPE_BUTTON_COLOR),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Lobby(gamemode: GameMode.escape),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget headerImage = Image.asset('assets/images/menu_logo.png');

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: newGameSelected
              ? [
                  headerImage,
                  const SizedBox(height: 80.0),
                  pvpGamemodeButton(),
                  const SizedBox(height: 20.0),
                  escapeGamemodeButton(),
                ]
              : [
                  headerImage,
                  const SizedBox(height: 80.0),
                  newGameButton(),
                  const SizedBox(height: 20.0),
                  const JoinGameButton(),
                ],
        ),
      ),
    );
  }
}
