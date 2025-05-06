import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:smart_lock_app/pages/lock/lock_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.uid});

  final String title;
  final String uid;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<dynamic, dynamic>> locks = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchLocks();
  }

  Future<void> _fetchLocks() async {
    try {
      final snapshot = await FirebaseDatabase.instance.ref(widget.uid).get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          locks = data.entries.map((e) => {'id': e.key, ...e.value}).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Lỗi khi tải dữ liệu: $e';
        isLoading = false;
      });
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
        drawer: const NavigationDrawer(),
        body: _myListDoor(context),
      ),
    );
  }

  Widget _myListDoor(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(child: Text(error!));
    }
    return ListView(
      children:
          ListTile.divideTiles(
            context: context,
            tiles: locks.map((lock) {
              return ListTile(
                title: Text(lock['name']),
                leading: Icon(
                  lock['state'] == 1 ? Icons.lock : Icons.lock_open,
                  color: lock['state'] == 1 ? Colors.green : Colors.red,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => DoorPage(
                            title: lock['name'],
                            uid: widget.uid,
                            id: lock['id'],
                          ),
                    ),
                  );
                },
              );
            }),
          ).toList(),
    );
  }
}

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) => Drawer(
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // buildHeader(context),
          buildMenuItems(context),
        ],
      ),
    ),
  );

  // Widget buildHeader(BuildContext context) =>Container(padding: EdgeInsets.only(top: (data: data, child: child).of(context).padding(top)),)
  Widget buildMenuItems(BuildContext context) => Column(
    children: [ListTile(title: const Text('Change password'), onTap: () {})],
  );
}
