// socketio client
import 'dart:io';

import 'package:socket_io_client/socket_io_client.dart';

// socket server url
const String socketUrl = 'http://hnr.puddle.sg:3000';
// const String socketUrl = 'http://localhost:3000';

Socket _socket = io(
    socketUrl,
    OptionBuilder()
        .setTransports(['websocket']) // for Flutter or Dart VM
        .disableAutoConnect() // disable auto-connection
        .build());

// init socket
Socket init() {
  // connect to socket server
  return _socket.connect();
}

// get socket
Socket getSocket() {
  return _socket;
}
