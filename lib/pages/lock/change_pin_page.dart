import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ChangePinPage extends StatefulWidget {
  const ChangePinPage({
    super.key,
    required this.title,
    required this.uid,
    required this.id,
  });

  final String title;
  final String uid;
  final String id;

  @override
  State<StatefulWidget> createState() => _ChangePinPageState();
}

class _ChangePinPageState extends State<ChangePinPage> {
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  String? error;

  Future<void> _changePIN(String newPIN) async {
    try {
      await FirebaseDatabase.instance
          .ref('${widget.uid}/${widget.id}/PIN')
          .set(newPIN);
    } catch (e) {
      error = 'Failed to change PIN: $e';
    }
  }

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
                      final newPIN = _newPinController.text.trim();
                      final confirmPIN = _confirmPinController.text.trim();

                      if (newPIN.isEmpty && confirmPIN.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Vui lòng nhập đầy đủ")),
                        );
                      } else if (newPIN.length != 4 ||
                          int.tryParse(newPIN) == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Vui lòng nhập 4 chữ số"),
                          ),
                        );
                      } else if (newPIN != confirmPIN) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Vui lòng nhập PIN xác nhận trùng với PIN mới",
                            ),
                          ),
                        );
                      } else {
                        _changePIN(newPIN);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Thành công")),
                        );
                        Navigator.pop(context);
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
