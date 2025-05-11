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
          await FirebaseDatabase.instance
              .ref('${widget.uid}/${widget.id}/cards')
              .get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          cards = data.entries.map((e) => {'id': e.key, ...e.value}).toList();
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
      await FirebaseDatabase.instance
          .ref('${widget.uid}/${widget.id}/cards/$cardID')
          .remove();
      setState(() {
        cards.removeWhere((card) => card['id'] == cardID);
      });
    } catch (e) {
      error = 'Failed to delete card: $e';
    }
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
        onPressed: () {},
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
                title: Text(card['id']),
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
