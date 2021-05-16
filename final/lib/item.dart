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
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'item_detail.dart';
import 'login.dart';

class Item {
  Item({
    @required this.id,
    @required this.author,
    @required this.imageURL,
    @required this.name,
    @required this.price,
    @required this.description,
    @required this.creationTime,
    @required this.updatedTime,
    @required this.likeUsers,
  });
  final String id;
  final String author;
  final String imageURL;
  final String name;
  final int price;
  final String description;
  final Timestamp creationTime;
  final Timestamp updatedTime;
  final List<dynamic> likeUsers;
}

class ItemPage extends StatefulWidget {
  @override
  _ItemPageState createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  List<Item> items = [];
  List<Item> reversedItems = [];
  StreamSubscription<QuerySnapshot> _itemSubscription;
  bool isAscending = true;
  String dropdownValue = 'ASC';

  @override
  void initState() {
    super.initState();
  }

  Future<List<Item>> loadImages() async {
    _itemSubscription = FirebaseFirestore.instance
        .collection('items')
        .orderBy('price', descending: true)
        .snapshots()
        .listen((snapshot) {
      items = [];
      snapshot.docs.forEach((document) async {
        String imageURL = await firebase_storage.FirebaseStorage.instance
            .ref(document.data()['name'])
            .getDownloadURL();
        items.add(
          Item(
            id: document.id,
            author: document.data()['author'],
            imageURL: imageURL,
            name: document.data()['name'],
            price: document.data()['price'],
            description: document.data()['description'],
            creationTime: document.data()['creation_time'],
            updatedTime: document.data()['recent_update_time'],
            likeUsers: document.data()['like_users'],
          ),
        );
        //print('items: $items');
        items.sort((a, b) => a.price.compareTo(b.price));
        reversedItems = items.reversed.toList();
      });
    });
    return Future.delayed(Duration(seconds: 2), () {
      return isAscending ? items : reversedItems;
    });
  }

  List<Card> _buildGridCards(List<Item> items) {
    if (items == null || items.isEmpty) {
      return const <Card>[];
    }
    final ThemeData theme = Theme.of(context);

    final NumberFormat formatter = NumberFormat.simpleCurrency(
        locale: Localizations.localeOf(context).toString());

    return items.map((item) {
      return Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 18 / 11,
              child: Image.network(
                item.imageURL,
                fit: BoxFit.fitWidth,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    formatter.format(item.price),
                    style: TextStyle(
                      fontSize: 10.0,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ItemDetailPage(item: item)),
                    );
                  },
                  child: Text('more'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    textStyle: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main'),
        leading: IconButton(
          icon: Icon(Icons.person),
          onPressed: () {
            Navigator.pushNamed(context, '/profile');
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.add,
              semanticLabel: 'add',
            ),
            onPressed: () => Navigator.pushNamed(context, '/item_add'),
          ),
        ],
      ),
      body: Consumer<ApplicationState>(
        builder: (context, appState, _) => FutureBuilder(
          future: loadImages(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData == false) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(fontSize: 15),
                ),
              );
            } else {
              return Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: 10.0, right: 16.0),
                    alignment: Alignment.centerRight,
                    child: DropdownButton<String>(
                      value: dropdownValue,
                      icon: const Icon(Icons.arrow_downward),
                      iconSize: 20,
                      onChanged: (String newValue) {
                        setState(() {
                          dropdownValue = newValue;
                          isAscending = !isAscending;
                        });
                      },
                      items: <String>['ASC', 'DESC']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      padding: EdgeInsets.all(16.0),
                      childAspectRatio: 8.0 / 9.0,
                      children: _buildGridCards(snapshot.data),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
      resizeToAvoidBottomInset: true,
    );
  }
}
