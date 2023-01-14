import 'package:socket_io_client/socket_io_client.dart';

import '../utils/sockets.dart';

class Handler{
  String roomId = '';
  Function render = (){};
  Socket socket = getSocket();
  int packetsSent = 0;
  List<Map<String, int>> packetCache = [];
  int serverTicks = 0;
  Map<String, List<int>> locations = {};

  void applyPacket(locations, input){
      if (((1 << 0) & input)!=0) {
        locations[socket.id][0]--;
      }
      if (((1 << 1) & input) != 0) {
        locations[socket.id][0]++;
      }
      if (((1 << 2) & input)!=0) {
        locations[socket.id][1]--;
      }
      if (((1 << 3) & input) !=0) {
        locations[socket.id][1]++;
      }
    }

  void sendInput(input){
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

  void joinRoom(){
    socket.emitWithAck('joinRoom', roomId, ack: (data){
      print(data);
    });
  }
  void startGame(){
    socket.emit('startGame', roomId);
  }


  Handler(roomId, render){
    roomId = roomId;
    render = render;
    
    socket.on('playerLocations', (data) => {
      print(data);
      packetCache = packetCache.where((p) => p.packetNumber > packetNumber).toList();

      serverTicks = data.serverTicks;
      locations = data.locations;
      packetCache.forEach((p) => {
        applyPacket(locations, p.input);
      });
      render(locations);
    });
  }
}

