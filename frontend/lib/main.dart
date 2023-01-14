import 'package:attention_game/screens/menu.dart';
import 'package:attention_game/colors.dart';
import 'package:attention_game/utils/sockets.dart';
import 'package:flutter/material.dart';

void main() {
  init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: const Color(BACKGROUND_COLOR)),
      home: const Menu(),
    );
  }
}
