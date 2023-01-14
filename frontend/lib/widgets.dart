import 'package:flutter/material.dart';

// ignore: constant_identifier_names
const double MENU_BUTTON_HEIGHT = 60;
// ignore: constant_identifier_names
const double MENU_BUTTON_WIDTH = 300;
// ignore: constant_identifier_names
const double MENU_BUTTON_FONT_SIZE = 17;

class MenuButton extends StatelessWidget {
  final String buttonText;
  final Color? backgroundColor;
  final void Function()? onPressed;

  const MenuButton({
    super.key,
    required this.buttonText,
    required this.backgroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0.0,
        fixedSize: const Size(MENU_BUTTON_WIDTH, MENU_BUTTON_HEIGHT),
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      child: Text(
        buttonText,
        style: const TextStyle(fontSize: MENU_BUTTON_FONT_SIZE),
      ),
    );
  }
}
