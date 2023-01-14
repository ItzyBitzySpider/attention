import 'dart:convert';

import 'package:attention_game/game/types/join_room_Result.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../utils/sockets.dart';

class Handler {
  static String roomId = '';
  static Socket socket = getSocket();
  static int packetsSent = 0;
  static List<dynamic> maze = [];

  static List<Map<String, int>> packetCache = [];
  static int serverTicks = 0;

  static Map locations = {};
  static List<dynamic> hearts = [];
  static int playersLeft = 0;
  static Map lives = {};

  static void applyPacket(locations, input) {
    if (((1 << 0) & input) != 0) {
      locations[socket.id][0]--;
    }
    if (((1 << 1) & input) != 0) {
      locations[socket.id][0]++;
    }
    if (((1 << 2) & input) != 0) {
      locations[socket.id][1]--;
    }
    if (((1 << 3) & input) != 0) {
      locations[socket.id][1]++;
    }
  }

  static get ownLocation {
    var _loc = locations[socket.id] ?? [0, 0];
    return [_loc[0], _loc[1]];
  }

  static void sendInput(int input) {
    Map<String, int> packet = {
      'packetNumber': packetsSent,
      'input': input,
      'serverTicks': serverTicks,
    };
    packetCache.add(packet);
    socket.emit('playerInput', packet);
    packetsSent++;
    applyPacket(locations, input);
  }

  static void createRoom(gamemode, callback) {
    socket.emitWithAck('createRoom', gamemode, ack: (data) {
      roomId = data;
      callback(roomId);
    });
  }

  static void joinRoom(room, callback) {
    socket.emitWithAck('joinRoom', room, ack: (data) {
      if (data['gameMode'] != '') roomId = room;
      print(data);
      callback(data['gameMode'], data['numPlayers']);
    });
  }

  static void updatePlayerCount(updateCount) {
    socket.on('updateUsers', (data) {
      updateCount(data);
    });
  }

  static void startGame() {
    socket.emitWithAck('startGame', roomId, ack: (data) {});
  }

  static void setSpectator(isSpectator) {
    Map<String, dynamic> packet = {
      'roomId': roomId,
      'isSpectator': isSpectator
    };
    socket.emit('setSpectator', packet);
  }

  static void listenForStart(callback) {
    socket.on('maze', (data) {
      maze = data;
      callback();
    });
  }

  static void startGameLoop() {
    socket.on('playerLocations', (data) {
      packetCache = packetCache
          .where((p) => ((p["packetNumber"] ?? 0) > data['packetNumber']))
          .toList();

      serverTicks = data['serverTicks'];
      // print(data['locations'].toString());
      // parse json

      var _tmpLocations = json.decode(data['locations']);
      packetCache.forEach((p) {
        applyPacket(_tmpLocations, p["input"]);
      });
      locations = _tmpLocations;
    });
  }

  static void pvp(shrinkMaze, hitPlayer, updatePlayersLeft, updateLives) {
    socket.on('hearts', (data) {
      print(data);
      hearts = data;
    });

    socket.on('updateLives', (data) {
      print(data);
      var _tmplives = json.decode(data['lives']);
      lives = _tmplives;
      playersLeft = data['playersLeft'];
      updateLives(_tmplives[socket.id]);
      updatePlayersLeft(data['playersLeft']);
    });

    socket.on('shrinkMaze', (data) {
      // shrinkMaze(data[0]);
    });

    // socket.on('hit', hitPlayer);
  }
}
