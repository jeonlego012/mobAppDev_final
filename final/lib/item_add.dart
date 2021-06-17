import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'model/item.dart';
import 'model/item_transaction.dart';

class ItemAddPage extends StatefulWidget {
  @override
  _ItemAddPageState createState() => _ItemAddPageState();
}

class _ItemAddPageState extends State<ItemAddPage> {
  File _image;
  final picker = ImagePicker();
  final _formKey = GlobalKey<FormState>(debugLabel: '_ItemAddPageState');
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    Widget imageSection = Container(
      child: _image == null
          ? Image.asset(
              'assets/default.png',
              width: 600,
              height: 240,
              fit: BoxFit.fitWidth,
            )
          : Image.file(
              _image,
              width: 600,
              height: 240,
              fit: BoxFit.fitWidth,
            ),
    );
    Widget iconSection = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        IconButton(
            icon: Icon(Icons.photo_camera),
            onPressed: () {
              getImage();
            }),
      ],
    );
    Widget textSection = Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.only(left: 50.0, right: 50.0),
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Product Name',
                  hintStyle: TextStyle(fontWeight: FontWeight.bold),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter product name to continue';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  hintText: 'Price',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter product price to continue';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Description',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter product description to continue';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                primary: Colors.white,
              ),
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            Padding(
              padding: EdgeInsets.only(left: 75.0, right: 100.0),
              child: Text('Add'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                primary: Colors.white,
              ),
              child: Text('Save'),
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  addItem(
                      Item(
                        userId: _firebaseAuth.currentUser.uid,
                        name: _nameController.text,
                        price: num.tryParse(_priceController.text),
                        description: _descriptionController.text,
                        creationTime: Timestamp.now(),
                      ),
                      _image);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          imageSection,
          iconSection,
          textSection,
        ],
      ),
    );
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected');
      }
    });
  }
}
