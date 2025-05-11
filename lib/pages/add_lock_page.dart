import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/material.dart';
import 'package:smart_lock_app/services/bluetooth.dart';

class AddLockPage extends StatefulWidget {
  const AddLockPage({super.key});

  @override
  State<AddLockPage> createState() => _AppLockPageState();
}

class _AppLockPageState extends State<AddLockPage> {
  List<BluetoothDevice> _devices = [];
  List<ScanResult> _scanResults = [];

  bool _isScanning = true;

  // BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;

  late StreamSubscription<BluetoothAdapterState> _adapterStateStateSubscription;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;

  final TextEditingController _wifiName = TextEditingController();
  final TextEditingController _wifiPassword = TextEditingController();

  @override
  void initState() {
    super.initState();
    scanDevices();
    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      if (mounted) {
        setState(() => _scanResults = results);
      }
    }, onError: (e) {});

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      if (mounted) {
        setState(() => _isScanning = state);
      }
    });
  }

  @override
  void dispose() {
    _adapterStateStateSubscription.cancel();
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    super.dispose();
  }

  Future scanDevices() async {
    try {
      // `withServices` is required on iOS for privacy purposes, ignored on android.
      var withServices = [Guid("180f")]; // Battery Level Service
      _devices = await FlutterBluePlus.systemDevices(withServices);
    } catch (e, backtrace) {
      print(e);
      print("backtrace: $backtrace");
    }
    try {
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 15),
        withServices: [
          // Guid("180f"), // battery
          // Guid("180a"), // device info
          // Guid("1800"), // generic access
          // Guid("6e400001-b5a3-f393-e0a9-e50e24dcca9e"), // Nordic UART
        ],
        webOptionalServices: [
          Guid("180f"), // battery
          Guid("180a"), // device info
          Guid("1800"), // generic access
          Guid("6e400001-b5a3-f393-e0a9-e50e24dcca9e"), // Nordic UART
        ],
      );
      _isScanning = false;
    } catch (e, backtrace) {
      print(e);
      print("backtrace: $backtrace");
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _showWifiDialog(BluetoothDevice d) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return wifiDialog(d: d);
      },
    );
  }

  Future<void> connectDevice() async {}

  Iterable<Widget> _buildScanResultTiles() {
    return _scanResults.map((r) {
      if (r.device.platformName.isNotEmpty) {
        return ListTile(
          title: Text(r.device.advName),
          onTap: () async {
            await for (var state in r.device.connectionState) {
              if (state == BluetoothConnectionState.connected) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Device is already connected!")),
                );
                _showWifiDialog(r.device);
                return;
              } else if (state == BluetoothConnectionState.disconnected) {
                try {
                  await r.device.connect(mtu: null);
                  _showWifiDialog(r.device);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to connect: $e")),
                  );
                }
                return;
              }
            }
          },
        );
      }
      return const SizedBox.shrink();
    });
  }

  List<Widget> _buildSystemDeviceTiles() {
    return _devices
        .map(
          (d) =>
              ListTile(title: Text(d.advName), onTap: () => _showWifiDialog(d)),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Choose a device')),
      body:
          _isScanning
              ? Center(child: CircularProgressIndicator())
              : ListView(
                children: <Widget>[
                  ..._buildSystemDeviceTiles(),
                  ..._buildScanResultTiles(),
                ],
              ),
    );
  }

  Widget wifiDialog({required BluetoothDevice d}) {
    return AlertDialog(
      title: Text('Wifi information'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _wifiName,
              decoration: InputDecoration(labelText: 'Wifi name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _wifiPassword,
              decoration: InputDecoration(labelText: 'Password'),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Đóng dialog
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            await MyBluetoothService().write(
              d: d,
              wifiName: 'n${_wifiName.text}',
              wifiPassword: 'p${_wifiPassword.text}',
            );
          },
          child: const Text('Connect'),
        ),
      ],
    );
  }
}
