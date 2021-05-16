import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login.dart';
import 'item.dart';
import 'item_edit.dart';

class ItemDetailPage extends StatefulWidget {
  final Item item;

  ItemDetailPage({Key key, @required this.item}) : super(key: key);

  @override
  _ItemDetailPageState createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  Future<void> showDeleteDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
          title: Text("Delete?"),
          content: Text("Do you want to delete?"),
          actions: [
            Consumer<ApplicationState>(
              builder: (context, appState, _) => FlatButton(
                child: Text("YES"),
                onPressed: () {
                  appState.deleteItemFromFirestore(widget.item.id);
                  appState.deleteImageFromStorage(widget.item.name);
                },
              ),
            ),
            FlatButton(
                child: Text("NO"),
                onPressed: () {
                  Navigator.pop(context);
                }),
          ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> itemLikers = widget.item.likeUsers;
    int likeNum = itemLikers.length;

    Future<void> pushLike(String itemId, List<dynamic> likeUsers) {
      FirebaseFirestore.instance.collection('items').doc(itemId).update({
        'like_users': likeUsers,
      });
      setState(() {
        itemLikers = likeUsers;
      });
    }

    Widget imageSection = Container(
      child: Image.network(
        widget.item.imageURL,
        fit: BoxFit.fitWidth,
      ),
    );
    Widget nameSection = Consumer<ApplicationState>(
      builder: (context, appState, _) => Row(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(30.0),
                child: Text(
                  widget.item.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 30.0, bottom: 10.0),
                child: Text(
                  '\$${widget.item.price}',
                ),
              ),
            ],
          ),
          Expanded(
            child: TextButton.icon(
              onPressed: () {
                if (itemLikers
                    .contains(FirebaseAuth.instance.currentUser.uid)) {
                  //itemLikers.remove(widget.item.author);
                  final snackBar = SnackBar(
                    content: Text('You can only do it once!'),
                    duration: Duration(milliseconds: 500),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                } else {
                  itemLikers.add(FirebaseAuth.instance.currentUser.uid);
                  pushLike(widget.item.id, itemLikers);
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
      ),
    );
    Widget descriptioinSection = Padding(
      padding: EdgeInsets.all(30.0),
      child: Text('${widget.item.description}'),
    );
    Widget dataSection = Padding(
      padding: EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('creator: ${widget.item.author}'),
          Text('${widget.item.creationTime.toDate()} Created'),
          widget.item.updatedTime != null
              ? Text('${widget.item.updatedTime.toDate()} Modified')
              : Text('not modified'),
        ],
      ),
    );
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Detail'),
        actions: <Widget>[
          FirebaseAuth.instance.currentUser.uid == widget.item.author
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
                              ItemEditPage(item: widget.item)),
                    );
                  },
                )
              : SizedBox(height: 1.0),
          FirebaseAuth.instance.currentUser.uid == widget.item.author
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
          imageSection,
          nameSection,
          _buildDivider(),
          descriptioinSection,
          dataSection,
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
