import 'dart:developer';
import 'dart:typed_data';
import 'package:socketiot/protocol/protocol.dart';
import 'package:socketiot/util/api.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WSClient {
  final Map<String, Function> _handlers;
  WebSocketChannel? _channel;

  WSClient() : _handlers = {};

  void connect(String host, String token) {
    _channel = IOWebSocketChannel.connect(Uri.parse(Api.ws));
    sendMessage(Protocol.auth, [token]);
    _channel?.stream.listen((event) {
      List<int> bytes = event;

      int len = bytes[0] << 8 | bytes[1];
      int type = bytes[2] << 8 | bytes[3];

      String message = String.fromCharCodes(
          bytes.sublist(Protocol.headerSize, len + Protocol.headerSize));
      List<String> args = message.split(String.fromCharCode(0));

      switch (type) {
        case Protocol.auth:
          if (args[0] == "1") {
            _handlers["authsuccess"]!.call();
          } else {
            _handlers["authfailed"]!.call();
          }
          break;
        case Protocol.write:
          _handlers["write"]!.call(id: args[0], pin: args[1], value: args[2]);
          break;
        case Protocol.deviceStatus:
          _handlers["status"]!.call(id: args[0], status: args[1]);
          break;
        case Protocol.ping:
          break;
      }
    });
  }

  void sendMessage(int type, [List<String>? args]) {
    String? arg = args?.join(String.fromCharCode(0));
    int len = arg?.length ?? 0;
    final message = Uint8List(Protocol.headerSize + len);
    message[0] = len >> 8;
    message[1] = len & 0xFF;
    message[2] = type >> 8;
    message[3] = type & 0xFF;
    for (int i = 0; i < len; i++) {
      message[Protocol.headerSize + i] = arg![i].codeUnitAt(0);
    }

    _channel?.sink.add(message);
  }

  void addEventListener(String name, Function callback) {
    _handlers[name] = callback;
  }

  void removeEventListener(String name) {
    _handlers.remove(name);
  }
}

final wsClient = WSClient();
