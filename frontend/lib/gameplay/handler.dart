import 'package:attention_game/game/types/join_room_Result.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../utils/sockets.dart';

class Handler {
  static String roomId = '';
  static Function render = () {};
  static Socket socket = getSocket();
  static int packetsSent = 0;
  static List<Map<String, int>> packetCache = [];
  static int serverTicks = 0;
  static Map<String, List<int>> locations = {};

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

  static void sendInput(input) {
    Map<String, int> packet = {
      'packetNumber': packetsSent,
      'input': input,
      'serverTicks': serverTicks,
    };
    packetCache.add(packet);
    socket.emit('playerInput', packet);
    packetsSent++;
    applyPacket(locations, input);
    render(locations);
  }

  static void createRoom(callback) {
    socket.emitWithAck('createRoom', '', ack: (data) => roomId = data);
  }

  static void joinRoom(room, callback) {
    socket.emitWithAck('createRoom', '', ack: (data) {
      JoinRoomResult _r = parseJoinRoomResult(data);
      callback(_r);
      roomId = room;
    });
  }

  static void startGame() {
    socket.emit('startGame', roomId);
  }

  static void startGameLoop(renderFn) {
    render = renderFn;

    socket.on('playerLocations', (data) {
      print(data);
      packetCache = packetCache
          .where((p) => ((p["packetNumber"] ?? 0) > data.packetNumber))
          .toList();

      serverTicks = data.serverTicks;
      locations = data.locations;
      packetCache.forEach((p) {
        applyPacket(locations, p["input"]);
      });
      render(locations);
    });
  }
}
