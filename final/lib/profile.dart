import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String email = FirebaseAuth.instance.currentUser.email;
  String id = FirebaseAuth.instance.currentUser.uid;

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    Widget imageSection = Container(
      child: Image.asset(
        email == null ? 'assets/default.png' : 'assets/profile.jpeg',
        width: 100,
        height: 100,
        fit: BoxFit.fill,
      ),
    );
    Widget idSection = Padding(
      padding: EdgeInsets.all(30.0),
      child: Text(
        '$id',
        style: TextStyle(fontSize: 16),
      ),
    );
    Widget emailSection = Padding(
      padding: EdgeInsets.all(20.0),
      child: email == null ? Text("Anonymous") : Text('$email'),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.logout,
              semanticLabel: 'logout',
            ),
            onPressed: () {
              signOut();
              Navigator.popUntil(context, ModalRoute.withName('/'));
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(30.0),
        child: Column(
          children: [
            imageSection,
            idSection,
            _buildDivider(),
            emailSection,
          ],
        ),
      ),
    );
  }

  Divider _buildDivider() {
    return const Divider(
      height: 10.0,
      indent: 20.0,
      endIndent: 20.0,
      color: Colors.black,
    );
  }
}
