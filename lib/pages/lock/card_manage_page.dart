import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class CardManagePage extends StatefulWidget {
  const CardManagePage({
    super.key,
    required this.title,
    required this.uid,
    required this.id,
  });

  final String title;
  final String uid;
  final String id;

  @override
  State<StatefulWidget> createState() => _CardManagePageState();
}

class _CardManagePageState extends State<CardManagePage> {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  List<Map<dynamic, dynamic>> cards = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _getCards();
  }

  Future<void> _getCards() async {
    try {
      final snapshot =
          await _database.ref('${widget.uid}/${widget.id}/cards').get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final filteredData = data.entries.where((e) => e.key != 'add');
        setState(() {
          cards = filteredData.map((e) => {'id': e.key, ...e.value}).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      error = 'Failed to load cards $e';
      isLoading = false;
    }
  }

  Future<void> _deleteCard(String cardID) async {
    try {
      await _database.ref('${widget.uid}/${widget.id}/cards/$cardID').remove();
      setState(() {
        cards.removeWhere((card) => card['id'] == cardID);
      });
    } catch (e) {
      error = 'Failed to delete card: $e';
    }
  }

  Future<void> _addCard(String name) async {
    try {
      final cardData = {'name': name, 'id': {}};
      final ref = _database.ref('${widget.uid}/${widget.id}/cards');

      final newCardRef = ref.push();

      final newCardKey = newCardRef.key;
      if (newCardKey == null) {
        throw Exception('Failed to generate card key');
      }
      await ref.child(newCardKey).set(cardData);
      await _database
          .ref('${widget.uid}/${widget.id}/cards/add')
          .set(newCardKey);
      setState(() {
        setState(() {
          cards.add({'id': newCardKey, 'name': name});
        });
      });
    } catch (e) {
      error = 'Failed to add card: $e';
    }
  }

  Future<void> _showDialog() async {
    TextEditingController name = TextEditingController();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter name'),
          content: TextField(
            controller: name,
            decoration: InputDecoration(labelText: "Name"),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _addCard(name.text.toString());
                Navigator.pop(context);
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: _listCard(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _listCard(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      children:
          ListTile.divideTiles(
            context: context,
            tiles: cards.map((card) {
              return ListTile(
                title: Text(card['name']),
                trailing: IconButton(
                  onPressed: () => _deleteCard(card['id']),
                  icon: const Icon(Icons.delete),
                ),
              );
            }),
          ).toList(),
    );
  }
}
