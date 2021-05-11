import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'login.dart';
import 'model/product.dart';

class ItemDetailPage extends StatefulWidget {
  final Product product;

  ItemDetailPage({Key key, @required this.product}) : super(key: key);

  @override
  _ItemDetailPageState createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  @override
  Widget build(BuildContext context) {
    // Widget imageSection = Container(
    //   child: Image.asset(
    //     widget.product.assetName,
    //     package: widget.product.assetPackage,
    //     width: 600,
    //     height: 240,
    //     fit: BoxFit.cover,
    //   ),
    // );
    // Widget nameSection = Consumer<ApplicationState>(
    //   builder: (context, appState, _) => Row(
    //     children: <Widget>[
    //       Column(
    //         children: [

    //         ],
    //       ),
    //     ],
    //   ),
    //   child: Text(
    //     widget.product.name,
    //     style: TextStyle(
    //       fontSize: 20,
    //       fontWeight: FontWeight.bold,
    //     ),
    //   ),
    // );
    Widget iconSection = Container(
      padding: EdgeInsets.fromLTRB(20.0, 15.0, 0.0, 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildIconRow(Icons.phone, widget.product.price),
        ],
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
          // imageSection,
          // nameSection,
          _buildDivider(),
          iconSection,
        ],
      ),
    );
  }

  Row _buildIconRow(IconData icon, int price) {
    return Row(
      children: [
        Container(
          margin: const EdgeInsets.only(right: 10.0),
          child: Icon(icon),
        ),
        Text(
          '$price',
        ),
      ],
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
