import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class MyBluetoothService {
  Future<void> write({
    required BluetoothDevice d,
    required String wifiName,
    required String wifiPassword,
  }) async {
    List<BluetoothService> services = [];
    List<int> wifiNameList = utf8.encode(wifiName);
    List<int> wifiPasswordList = utf8.encode(wifiPassword);

    try {
      services = await d.discoverServices();
      BluetoothCharacteristic c = services.last.characteristics.last;
      await c.write(wifiNameList);
      await c.write(wifiPasswordList);
    } catch (e) {}
  }
}
