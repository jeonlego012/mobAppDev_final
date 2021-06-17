// Copyright 2018-present the Flutter authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'home.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[
            SizedBox(height: 80.0),
            Column(
              children: <Widget>[
                Image.asset(
                  'assets/fish.png',
                  height: 80.0,
                  width: 90.0,
                ),
                SizedBox(height: 16.0),
              ],
            ),
            Consumer<ApplicationState>(
              builder: (context, appState, _) {
                if (appState.loggedIn) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Home(),
                        ));
                  });
                }
                return Column(
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(40.0, 40.0, 40.0, 5.0),
                      child: GoogleSignInButton(
                        centered: true,
                        onPressed: () {
                          appState.signInWithGoogle();
                        },
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(40.0, 5.0, 40.0, 10.0),
                      child: RaisedButton(
                        onPressed: () => appState.signInAnonymously(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Guest',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

class ApplicationState extends ChangeNotifier {
  bool loggedIn = false;
  StreamSubscription<QuerySnapshot> _itemSubscription;

  ApplicationState() {
    init();
  }

  Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user == null) {
        loggedIn = false;
        print('User is signed out!');
        //_items = [];
        //_itemSubscription.cancel();
      } else {
        //_items = [];
        loggedIn = true;
        print('User is signed in! ${user.email}');
      }
      notifyListeners();
    });
  }

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    notifyListeners();

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> signInAnonymously() async {
    UserCredential userCredential =
        await FirebaseAuth.instance.signInAnonymously();
    notifyListeners();
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    notifyListeners();
  }

  Future<void> addItemToFirestore(
      String itemName, int itemPrice, String itemDescription) {
    return FirebaseFirestore.instance.collection('items').add({
      'name': itemName,
      'price': itemPrice,
      'description': itemDescription,
      'creation_time': FieldValue.serverTimestamp(),
      'recent_update_time': null,
      'author': FirebaseAuth.instance.currentUser.uid,
      'like_users': <dynamic>[],
    }).then((value) {
      print("Item added to firestore $value");
      notifyListeners();
    }).catchError((error) => print("Failed to add item: $error"));
  }

  Future<void> editItemFromFirestore(
      String itemId, String itemName, int itemPrice, String itemDescription) {
    return FirebaseFirestore.instance.collection('items').doc(itemId).update({
      'name': itemName,
      'price': itemPrice,
      'description': itemDescription,
      'recent_update_time': FieldValue.serverTimestamp(),
    }).then((value) {
      print("Item edited to firestore");
      notifyListeners();
    }).catchError((error) => print("Filed to edit item: $error"));
  }

  Future<void> deleteItemFromFirestore(String itemId) {
    return FirebaseFirestore.instance
        .collection('items')
        .doc(itemId)
        .delete()
        .then((value) {
      print("Item edited to firestore");
      notifyListeners();
    }).catchError((error) => print("Filed to edit item: $error"));
  }

  Future<void> addImageToStorage(String imageName, File image) async {
    firebase_storage.SettableMetadata metadata =
        firebase_storage.SettableMetadata(
      customMetadata: <String, String>{
        'authorId': FirebaseAuth.instance.currentUser.uid,
      },
    );
    await firebase_storage.FirebaseStorage.instance
        .ref(imageName)
        .putFile(image, metadata)
        .then((value) {
      print("Item added to storage $value");
      notifyListeners();
    }).catchError((error) => print("Failed to add image: $error"));
  }

  Future<void> editImageFromStorage(String previous, String previousImagePath,
      String imageName, File image) async {
    firebase_storage.SettableMetadata metadata =
        firebase_storage.SettableMetadata(
      customMetadata: <String, String>{
        'authorId': FirebaseAuth.instance.currentUser.uid,
      },
    );
    if (image != null) {
      await firebase_storage.FirebaseStorage.instance
          .ref(previous)
          .delete()
          .then((value) {
        print("Item deleted from storage");
        notifyListeners();
      }).catchError((error) => print("Failed to delete image: $error"));
      await firebase_storage.FirebaseStorage.instance
          .ref(imageName)
          .putFile(image, metadata)
          .then((value) {
        print("Item added to storage $value");
        notifyListeners();
      }).catchError((error) => print("Failed to add image: $error"));
    } else {
      await firebase_storage.FirebaseStorage.instance
          .ref(imageName)
          .putFile(File(previousImagePath), metadata)
          .then((value) {
        print("Item added to storage $value");
        notifyListeners();
      }).catchError((error) => print("Failed to add image: $error"));
      await firebase_storage.FirebaseStorage.instance
          .ref(previous)
          .delete()
          .then((value) {
        print("Item deleted from storage");
      }).catchError((error) => print("Failed to delete image: $error"));
    }
  }

  Future<void> deleteImageFromStorage(String imageName) async {
    await firebase_storage.FirebaseStorage.instance
        .ref(imageName)
        .delete()
        .then((value) {
      print("Item deleted from storage");
      notifyListeners();
    }).catchError((error) => print("Failed to delete image: $error"));
  }
}
