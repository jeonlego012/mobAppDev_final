import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:Shrine/model/item.dart';
import 'package:Shrine/model/item_transaction.dart';
import 'package:Shrine/item_detail.dart';

class Body extends StatefulWidget {
  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  StreamSubscription<QuerySnapshot> _currentSubscription;
  List<Item> _items = <Item>[];

  _BodyState() {
    _currentSubscription = loadAllItems().listen(_updateItems);
  }

  @override
  void dispose() {
    _currentSubscription?.cancel();
    super.dispose();
  }

  void _updateItems(QuerySnapshot snapshot) {
    setState(() {
      _items = getItemsFromQuery(snapshot);
    });
  }

  List<Card> _buildGridCards(List<Item> items) {
    if (items == null || items.isEmpty) {
      return const <Card>[];
    }

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
                          builder: (context) =>
                              ItemDetailPage(itemId: item.id)),
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
    return Expanded(
      child: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(16.0),
        childAspectRatio: 8.0 / 9.0,
        children: _buildGridCards(_items),
      ),
    );
  }
}
