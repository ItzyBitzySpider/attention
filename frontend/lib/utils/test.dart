import 'dart:io';

import 'package:attention_game/utils/sockets.dart';
import 'package:socket_io_client/socket_io_client.dart';

main(){
  Socket socket = init();
  // send message
  socket.emitWithAck('createRoom', 'hello', ack: (data){
    print(data);
  });
}