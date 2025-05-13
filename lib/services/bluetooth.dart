import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class MyBluetoothService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> write({
    required BluetoothDevice d,
    required String name,
    required String pass,
  }) async {
    List<BluetoothService> services = [];
    List<int> wifiNameList = utf8.encode(name);
    List<int> wifiPasswordList = utf8.encode(pass);
    try {
      services = await d.discoverServices();
      BluetoothCharacteristic c = services.last.characteristics.last;

      await c.write(wifiNameList);
      await c.write(wifiPasswordList);
    } catch (e) {}
  }

  Future<void> writeInfo({
    required BluetoothDevice d,
    required String name,
    required String pass,
    required BuildContext context,
  }) async {
    List<BluetoothService> services = [];
    final user = _auth.currentUser;
    final ref = _database.ref(user?.uid);
    try {
      services = await d.discoverServices();
      BluetoothCharacteristic c = services.last.characteristics.last;
      if (user == null) {
        throw Exception('Failed to get user');
      }
      final newLockRef = ref.push();
      final newLockKey = newLockRef.key;

      if (newLockKey == null) {
        throw Exception('Failed to generate lock key');
      }
      int chunkSize = 19;
      for (int i = 0; i < user.uid.length; i += chunkSize) {
        int end =
            (i + chunkSize < user.uid.length) ? i + chunkSize : user.uid.length;
        String chunk = user.uid.substring(i, end);
        List<int> chunkList = utf8.encode('u$chunk');
        await c.write(chunkList);
        await Future.delayed(Duration(milliseconds: 50));
      }
      for (int i = 0; i < newLockKey.length; i += chunkSize) {
        int end =
            (i + chunkSize < newLockKey.length)
                ? i + chunkSize
                : newLockKey.length;
        String chunk = newLockKey.substring(i, end);
        List<int> chunkList = utf8.encode('i$chunk');
        await c.write(chunkList);
        await Future.delayed(Duration(milliseconds: 50));
      }
      final lockData = {'name': name, 'PIN': pass, 'state': 1, 'cards': {}};
      await ref.child(newLockKey).set(lockData);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), duration: Duration(seconds: 3)),
      );
    }
  }

  Future<String> read({required BluetoothDevice d}) async {
    List<BluetoothService> services = [];

    try {
      services = await d.discoverServices();
      BluetoothCharacteristic c = services.last.characteristics.last;
      List<int> value = await c.read();
      String received = '';
      received = utf8.decode(value);
      // StreamSubscription<List<int>>? subscription;
      // subscription = c.lastValueStream.listen((value) {
      //   if (value.isNotEmpty) {
      //     received = true;
      //   }
      // });

      // await subscription.cancel();
      return received;
    } catch (e) {
      return '';
    }
  }
}
