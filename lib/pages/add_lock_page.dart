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
  String receivedData = '';
  late StreamSubscription<BluetoothAdapterState> _adapterStateStateSubscription;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;

  final TextEditingController _wifiName = TextEditingController();
  final TextEditingController _wifiPassword = TextEditingController();
  final TextEditingController _lockName = TextEditingController();
  final TextEditingController _lockPIN = TextEditingController();

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
    _wifiName.dispose();
    _wifiPassword.dispose();
    super.dispose();
  }

  Future scanDevices() async {
    try {
      // withServices is required on iOS for privacy purposes, ignored on android.
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
    bool waiting = false;

    await showDialog(
      context: context,
      barrierDismissible: !waiting, // Dialog can't be dismissed when loading
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Wifi information'),
              content: SingleChildScrollView(
                child:
                    waiting
                        ? SizedBox(
                          height: 144,
                          child: Center(child: CircularProgressIndicator()),
                        )
                        : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: _wifiName,
                              decoration: const InputDecoration(
                                labelText: 'Wifi name',
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _wifiPassword,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                              ),
                            ),
                          ],
                        ),
              ),
              actions: <Widget>[
                if (!waiting)
                  TextButton(
                    onPressed: () {
                      _wifiPassword.clear();
                      _wifiName.clear();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                if (!waiting)
                  TextButton(
                    onPressed: () async {
                      setState(() {
                        waiting = true;
                      });

                      try {
                        await MyBluetoothService().write(
                          d: d,
                          name: 'n${_wifiName.text}',
                          pass: 'p${_wifiPassword.text}',
                        );
                        Future.delayed(const Duration(seconds: 10), () async {
                          receivedData = await MyBluetoothService().read(d: d);
                          if (!context.mounted) return;
                          if (receivedData == "Connected") {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(receivedData)),
                            );
                            setState(() {
                              waiting = false;
                            });
                            _showInfoDialog(d);
                          } else {
                            setState(() {
                              waiting = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Vui lòng nhập lại tên hoặc mật khẩu của wifi',
                                ),
                                duration: Duration(seconds: 3),
                              ),
                            );
                          }
                        });
                      } catch (e) {
                        if (context.mounted) {
                          setState(() {
                            waiting = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Connection failed: $e')),
                          );
                        }
                      }
                    },
                    child: const Text('Connect'),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showInfoDialog(BluetoothDevice d) async {
    bool waiting = false;
    await showDialog(
      context: context,
      barrierDismissible: !waiting, // Dialog can't be dismissed when loading
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Enter lock information'),
              content: SingleChildScrollView(
                child:
                    waiting
                        ? SizedBox(
                          height: 144,
                          child: Center(child: CircularProgressIndicator()),
                        )
                        : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: _lockName,
                              decoration: const InputDecoration(
                                labelText: 'Lock name',
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _lockPIN,
                              decoration: const InputDecoration(
                                labelText: 'PIN',
                              ),
                            ),
                          ],
                        ),
              ),
              actions: <Widget>[
                if (!waiting)
                  TextButton(
                    onPressed: () async {
                      final name = _lockName.text.trim();
                      final pin = _lockPIN.text.trim();
                      if (name.isEmpty || pin.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Vui lòng nhập đầy đủ")),
                        );
                      } else if (pin.length != 4 || int.tryParse(pin) == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Vui lòng nhập mã PIN 4 chữ số"),
                          ),
                        );
                      } else {
                        setState(() {
                          waiting = true;
                        });
                        try {
                          await MyBluetoothService().writeInfo(
                            d: d,
                            name: name,
                            pass: pin,
                            context: context,
                          );
                          Future.delayed(const Duration(seconds: 2), () async {
                            receivedData = await MyBluetoothService().read(
                              d: d,
                            );
                            if (!context.mounted) return;
                            if (receivedData == "Done") {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(receivedData)),
                              );
                              Navigator.of(context).pop();
                            } else {
                              setState(() {
                                waiting = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Vui lòng nhập lại tên hoặc mật khẩu của wifi',
                                  ),
                                  duration: Duration(seconds: 3),
                                ),
                              );
                            }
                          });
                        } catch (e) {
                          if (context.mounted) {
                            setState(() {
                              waiting = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Connection failed: $e')),
                            );
                          }
                        }
                      }
                    },
                    child: const Text('Connect'),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Iterable<Widget> _buildScanResultTiles() {
    return _scanResults.map((r) {
      if (r.device.platformName.isNotEmpty) {
        return ListTile(
          title: Text(r.device.advName),
          onTap: () async {
            await for (var state in r.device.connectionState) {
              receivedData = await MyBluetoothService().read(d: r.device);
              // if (!mounted) return;
              if (state == BluetoothConnectionState.connected) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(receivedData)));

                if (receivedData == "Connected") {
                  _showInfoDialog(r.device);
                } else {
                  _showWifiDialog(r.device);
                }
                return;
              } else if (state == BluetoothConnectionState.disconnected) {
                try {
                  await r.device.connect(mtu: null);
                  _showWifiDialog(r.device);
                } catch (e) {
                  if (!mounted) return;
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
      appBar: AppBar(title: const Text('Choose a device')),
      body:
          _isScanning
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                children: <Widget>[
                  ..._buildSystemDeviceTiles(),
                  ..._buildScanResultTiles(),
                ],
              ),
    );
  }
}
