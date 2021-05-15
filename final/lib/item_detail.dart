import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'login.dart';
import 'item.dart';

class ItemDetailPage extends StatefulWidget {
  final Item item;

  ItemDetailPage({Key key, @required this.item}) : super(key: key);

  @override
  _ItemDetailPageState createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  @override
  Widget build(BuildContext context) {
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
                padding: EdgeInsets.all(30.0),
                child: Text(
                  '\$${widget.item.price}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
    Widget descriptioinSection = Consumer<ApplicationState>(
      builder: (context, appState, _) => Padding(
        padding: EdgeInsets.all(30.0),
        child: Text('${widget.item.description}'),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Detail'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.edit,
              semanticLabel: 'edit',
            ),
            onPressed: () {
              print('edit!');
            },
          ),
          IconButton(
            icon: Icon(
              Icons.delete,
              semanticLabel: 'delete',
            ),
            onPressed: () {
              print('delete!');
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          imageSection,
          nameSection,
          _buildDivider(),
          descriptioinSection,
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
