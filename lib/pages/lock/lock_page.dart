import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:smart_lock_app/pages/lock/card_manage_page.dart';
import 'package:smart_lock_app/pages/lock/change_pin_page.dart';
import 'package:smart_lock_app/pages/home_page.dart';

class DoorPage extends StatefulWidget {
  const DoorPage({
    super.key,
    required this.title,
    required this.uid,
    required this.id,
  });

  final String title;
  final String uid;
  final String id;

  @override
  State<StatefulWidget> createState() => _DoorPageState();
}

class _DoorPageState extends State<DoorPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  bool _isLoading = true;
  bool _isLocked = true;

  @override
  void initState() {
    super.initState();
    _database.child('${widget.uid}/${widget.id}/state').onValue.listen((event) {
      setState(() {
        _isLocked = event.snapshot.value == 1;
        _isLoading = false;
      });
    });
  }

  void _toggleLockState() async {
    setState(() {
      _isLocked = !_isLocked;
    });
    await _database
        .child('${widget.uid}/${widget.id}/state')
        .set(_isLocked ? 1 : 0);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        drawer: NavigationDrawer(uid: widget.uid, id: widget.id),
        body:
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : Center(
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
                ),
      ),
    );
  }
}

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({super.key, required this.uid, required this.id});

  final String uid;
  final String id;

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
      ListTile(
        title: const Text('Home'),
        onTap: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => MyHomePage(title: "Smart Lock", uid: uid),
            ),
            (Route<dynamic> route) => false,
          );
        },
      ),
      ListTile(
        title: const Text('Change PIN'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      ChangePinPage(title: "Change PIN", uid: uid, id: id),
            ),
          );
        },
      ),
      ListTile(
        title: const Text('Card Management'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => CardManagePage(
                    title: "Card Management",
                    uid: uid,
                    id: id,
                  ),
            ),
          );
        },
      ),
    ],
  );
}
