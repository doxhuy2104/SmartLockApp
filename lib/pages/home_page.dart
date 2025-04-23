import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  bool _isLocked = true;

  @override
  void initState() {
    super.initState();
    _database.child('lock/state').onValue.listen((event) {
      setState(() {
        _isLocked = event.snapshot.value == 1;
      });
    });
  }

  void _toggleLockState() async {
    setState(() {
      _isLocked = !_isLocked;
    });
    await _database.child('lock/state').set(_isLocked ? 1 : 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      drawer: const NavigationDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: _toggleLockState,
              child: Image(
                image: AssetImage(
                  _isLocked
                      ? 'assets/images/lock.png'
                      : 'assets/images/unlock.png',
                ),
                width: 300,
                height: 300,
              ),
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
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
    children: [
      ListTile(title: const Text('Home'), onTap: () {}),
      ListTile(title: const Text('Change PIN'), onTap: () {}),
      ListTile(title: const Text('CardID'), onTap: () {}),
      ListTile(title: const Text('Change password'), onTap: () {}),
    ],
  );
}
