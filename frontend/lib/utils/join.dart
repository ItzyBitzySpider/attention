import 'dart:io';

import 'package:attention_game/utils/sockets.dart';
import 'package:socket_io_client/socket_io_client.dart';

main(){
  Socket socket = init();
  // send message
  socket.emitWithAck('joinRoom', 'v2hj63', ack: (data){
    print(data);
  });
  
  socket.emitWithAck('startGame', 'v2hj63', ack: (data){
    print(data);
  });

  socket.on('maze', (data) => {
    print(data)
  });
}