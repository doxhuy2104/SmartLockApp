import 'package:flutter/material.dart';

class ChangePinPage extends StatefulWidget {
  const ChangePinPage({super.key, required this.title});

  final String title;

  @override
  State<StatefulWidget> createState() => _ChangePinPageState();
}

class _ChangePinPageState extends State<ChangePinPage> {
  final _oldPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Center(
          // padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _oldPinController,
                  decoration: InputDecoration(labelText: 'Old PIN'),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _newPinController,
                  decoration: InputDecoration(labelText: 'New PIN'),
                ),
                const SizedBox(height: 24),

                TextField(
                  controller: _confirmPinController,
                  decoration: InputDecoration(labelText: 'Confirm PIN'),
                ),
                const SizedBox(height: 24),

                //Confirm button
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () async {
                      final oldPIN = _oldPinController.text.trim();
                      final newPIN = _newPinController.text.trim();
                      final confirmPIN = _confirmPinController.text.trim();

                      if (oldPIN.isNotEmpty &&
                          newPIN.isNotEmpty &&
                          confirmPIN.isNotEmpty) {
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Vui lòng nhập đầy đủ")),
                        );
                      }
                    },
                    child: const Text('Confirm'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
