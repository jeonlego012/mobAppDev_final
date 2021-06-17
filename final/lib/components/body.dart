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
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

// import 'item_detail.dart';
// import 'login.dart';

// class ItemPage extends StatefulWidget {
//   @override
//   _ItemPageState createState() => _ItemPageState();
// }

// class _ItemPageState extends State<ItemPage> {
//   List<Item> items = [];
//   List<Item> reversedItems = [];
//   StreamSubscription<QuerySnapshot> _itemSubscription;
//   bool isAscending = true;
//   String dropdownValue = 'ASC';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Main'),
//         leading: IconButton(
//           icon: Icon(Icons.person),
//           onPressed: () {
//             Navigator.pushNamed(context, '/profile');
//           },
//         ),
//         actions: <Widget>[
//           IconButton(
//             icon: Icon(
//               Icons.add,
//               semanticLabel: 'add',
//             ),
//             onPressed: () => Navigator.pushNamed(context, '/item_add'),
//           ),
//         ],
//       ),
//       body: Consumer<ApplicationState>(
//         builder: (context, appState, _) => FutureBuilder(
//           future: loadImages(),
//           builder: (BuildContext context, AsyncSnapshot snapshot) {
//             if (snapshot.hasData == false) {
//               return CircularProgressIndicator();
//             } else if (snapshot.hasError) {
//               return Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(
//                   'Error: ${snapshot.error}',
//                   style: TextStyle(fontSize: 15),
//                 ),
//               );
//             } else {
//               return Column(
//                 children: <Widget>[
//                   Container(
//                     padding: EdgeInsets.only(top: 10.0, right: 16.0),
//                     alignment: Alignment.centerRight,
//                     child: DropdownButton<String>(
//                       value: dropdownValue,
//                       icon: const Icon(Icons.arrow_downward),
//                       iconSize: 20,
//                       onChanged: (String newValue) {
//                         setState(() {
//                           dropdownValue = newValue;
//                           isAscending = !isAscending;
//                         });
//                       },
//                       items: <String>['ASC', 'DESC']
//                           .map<DropdownMenuItem<String>>((String value) {
//                         return DropdownMenuItem<String>(
//                           value: value,
//                           child: Text(value),
//                         );
//                       }).toList(),
//                     ),
//                   ),
//                   Expanded(
//                     child: GridView.count(
//                       crossAxisCount: 2,
//                       padding: EdgeInsets.all(16.0),
//                       childAspectRatio: 8.0 / 9.0,
//                       children: _buildGridCards(snapshot.data),
//                     ),
//                   ),
//                 ],
//               );
//             }
//           },
//         ),
//       ),
//       resizeToAvoidBottomInset: true,
//     );
//   }
// }
