import 'dart:io';

import 'package:osc/osc.dart';
import 'package:udp/udp.dart';

void main(List<String> arguments) async {
  final soc = OSCSocket(
      destination: InternetAddress.tryParse("192.168.0.60"),
      destinationPort: 50010);

  final udp = await UDP.bind(Endpoint.any(port: Port(50011)));
  udp.asStream().listen((event) {
    if (event == null) return;
    try {
      final msg = OSCMessage.fromBytes(event.data);
      final ch =
          int.parse(msg.address.substring(msg.address.lastIndexOf('/') + 1));
      final level = msg.arguments[0] as double;
      print('$ch,$level');
    } catch (e) {
      print(e);
    }
  });

  await soc.send(OSCMessage("/dbaudio1/matrixnode/enable/1/6", arguments: []));

  for (int i = 0; i < 100; i++) {
    for (int ch = 0; ch < 64; ch++) {
      soc.send(OSCMessage("/dbaudio1/matrixinput/levelmeterpremute/${ch + 1}",
          arguments: []));
    }
    await Future.delayed(Duration(milliseconds: 50));
  }
}
