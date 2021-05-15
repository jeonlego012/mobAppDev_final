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
    @required this.imageURL,
    @required this.name,
    @required this.price,
    @required this.description,
  });
  final String imageURL;
  final String name;
  final int price;
  final String description;
}

class ItemPage extends StatefulWidget {
  @override
  _ItemPageState createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  List<Item> _items = [];
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
              padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.name,
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    formatter.format(item.price),
                    style: theme.textTheme.subtitle2,
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

  List<Item> loadItems() {
    StreamSubscription<QuerySnapshot> _itemSubscription;

    _itemSubscription = FirebaseFirestore.instance
        .collection('items')
        .orderBy('price', descending: true)
        .snapshots()
        .listen((snapshot) {
      _items = [];
      snapshot.docs.forEach((document) async {
        String imageURL = await firebase_storage.FirebaseStorage.instance
            .ref(document.data()['name'])
            .getDownloadURL();
        _items.add(
          Item(
            imageURL: imageURL,
            name: document.data()['name'],
            price: document.data()['price'],
            description: document.data()['description'],
          ),
        );
        print("loaditem : $_items");
      });
    });
    return _items;
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
        builder: (context, appState, _) {
          appState.items.sort((a, b) => a.price.compareTo(b.price));
          List<Item> reversed_items = appState.items.reversed.toList();
          print(appState.items);
          return Column(
            children: <Widget>[
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  padding: EdgeInsets.all(16.0),
                  childAspectRatio: 8.0 / 9.0,
                  //children: _buildGridCards(appState.items),
                  children: _buildGridCards(reversed_items),
                ),
              ),
            ],
          );
        },
        /*FutureBuilder(
            future: appState.loadItems(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              print(snapshot);
              if (snapshot.hasData == false) {
                print(appState.items);
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                print(appState.items);
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(fontSize: 15),
                  ),
                );
              } else {
                print(appState.items);
                appState.items.sort((a, b) => a.price.compareTo(b.price));
                List<Item> reversed_items = appState.items.reversed.toList();
                return Column(
                  children: <Widget>[
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        padding: EdgeInsets.all(16.0),
                        childAspectRatio: 8.0 / 9.0,
                        //children: _buildGridCards(appState.items),
                        children: _buildGridCards(reversed_items),
                      ),
                    ),
                  ],
                );
              }
            }),*/
      ),
      resizeToAvoidBottomInset: true,
    );
  }

  /*Future<void> loadItems() {
    StreamSubscription<QuerySnapshot> _itemSubscription;

    _itemSubscription = FirebaseFirestore.instance
        .collection('items')
        .orderBy('price', descending: true)
        .snapshots()
        .listen((snapshot) {
      _items = [];
      snapshot.docs.forEach((document) async {
        String imageURL = await firebase_storage.FirebaseStorage.instance
            .ref(document.data()['name'])
            .getDownloadURL();
        _items.add(
          Item(
            imageURL: imageURL,
            name: document.data()['name'],
            price: document.data()['price'],
            description: document.data()['description'],
          ),
        );
      });
    });
  }*/
}
