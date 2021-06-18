import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'model/item.dart';
import 'model/item_transaction.dart';
import 'item_edit.dart';
import 'home.dart';

class ItemDetailPage extends StatefulWidget {
  final String _itemId;

  ItemDetailPage({
    Key key,
    @required String itemId,
  })  : _itemId = itemId,
        super(key: key);

  @override
  _ItemDetailPageState createState() => _ItemDetailPageState(itemId: _itemId);
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  bool _isLoading = true;
  Item _item;
  List<dynamic> _itemLikers = <dynamic>[];
  int likeNum;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  _ItemDetailPageState({@required String itemId}) {
    getItem(itemId).then((Item item) {
      setState(() {
        _item = item;
        print('item : ${_item.id}');
        _itemLikers = _item.likeUsers;
        likeNum = _itemLikers.length;
        _isLoading = false;
      });
    });
  }

  Future<void> pushLike(String itemId, List<dynamic> likeUsers) {
    FirebaseFirestore.instance.collection('items').doc(itemId).update({
      'like_users': likeUsers,
    });
    setState(() {
      _itemLikers = likeUsers;
      likeNum = _itemLikers.length;
    });
  }

  Future<void> showDeleteDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
          title: Text("Delete?"),
          content: Text("Do you want to delete?"),
          actions: [
            FlatButton(
              child: Text("YES"),
              onPressed: () {
                deleteItem(_item.id);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Home()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
            FlatButton(
                child: Text("NO"),
                onPressed: () {
                  Navigator.pop(context);
                }),
          ]),
    );
  }

  Container imageSection() {
    return Container(
      child: Image.network(
        _item.imageURL,
        fit: BoxFit.fitWidth,
      ),
    );
  }

  Row nameSection() {
    return Row(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(30.0),
              child: Text(
                _item.name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 30.0, bottom: 10.0),
              child: Text(
                '\$${_item.price}',
              ),
            ),
          ],
        ),
        Expanded(
          child: TextButton.icon(
            onPressed: () {
              if (_itemLikers.contains(FirebaseAuth.instance.currentUser.uid)) {
                final snackBar = SnackBar(
                  content: Text('You can only do it once!'),
                  duration: Duration(milliseconds: 500),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              } else {
                _itemLikers.add(FirebaseAuth.instance.currentUser.uid);
                pushLike(_item.id, _itemLikers);
                final snackBar = SnackBar(
                  content: Text('I LIKE IT!'),
                  duration: Duration(milliseconds: 500),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            },
            icon: Icon(Icons.thumb_up),
            label: Text('$likeNum'),
          ),
        ),
      ],
    );
  }

  Padding descriptionSection() {
    return Padding(
      padding: EdgeInsets.all(30.0),
      child: Text('${_item.description}'),
    );
  }

  Padding dataSection() {
    return Padding(
      padding: EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('creator: ${_item.userId}'),
          Text('${_item.creationTime.toDate()} Created'),
          _item.updatedTime != null
              ? Text('${_item.updatedTime.toDate()} Modified')
              : Text('not modified'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Scaffold(body: Center(child: CircularProgressIndicator()))
        : Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text('Detail'),
              actions: <Widget>[
                _firebaseAuth.currentUser.uid == _item.userId
                    ? IconButton(
                        icon: Icon(
                          Icons.edit,
                          semanticLabel: 'edit',
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ItemEditPage(itemId: widget._itemId)),
                          );
                        },
                      )
                    : SizedBox(height: 1.0),
                _firebaseAuth.currentUser.uid == _item.userId
                    ? IconButton(
                        icon: Icon(
                          Icons.delete,
                          semanticLabel: 'delete',
                        ),
                        onPressed: () => showDeleteDialog(),
                      )
                    : SizedBox(height: 1.0),
              ],
            ),
            body: ListView(
              children: [
                imageSection(),
                nameSection(),
                _buildDivider(),
                descriptionSection(),
                dataSection(),
              ],
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
