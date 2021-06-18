import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'model/item.dart';
import 'model/item_transaction.dart';
import 'home.dart';

class ItemEditPage extends StatefulWidget {
  ItemEditPage({Key key, @required String itemId})
      : _itemId = itemId,
        super(key: key);
  final String _itemId;

  @override
  _ItemEditPageState createState() => _ItemEditPageState(itemId: _itemId);
}

class _ItemEditPageState extends State<ItemEditPage> {
  bool _isLoading = true;
  File _image;
  final picker = ImagePicker();
  final _formKey = GlobalKey<FormState>(debugLabel: '_ItemEditPageState');
  TextEditingController _nameController,
      _priceController,
      _descriptionController;

  Item _item;

  _ItemEditPageState({@required String itemId}) {
    getItem(itemId).then((Item item) {
      setState(() {
        _item = item;
        _nameController = TextEditingController(text: '${_item.name}');
        _priceController = TextEditingController(text: '${_item.price}');
        _descriptionController =
            TextEditingController(text: '${_item.description}');
        _isLoading = false;
      });
    });
  }

  Container imageSection() {
    return Container(
        child: _image == null
            ? Image.network(
                _item.imageURL,
                width: 600,
                height: 240,
                fit: BoxFit.fitWidth,
              )
            : Image.file(
                _image,
                width: 600,
                height: 240,
                fit: BoxFit.fitWidth,
              ));
  }

  Row iconSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        IconButton(
            icon: Icon(Icons.photo_camera),
            onPressed: () {
              getImage();
            }),
      ],
    );
  }

  Padding textSection() {
    return Padding(
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
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Scaffold(body: Center(child: CircularProgressIndicator()))
        : Scaffold(
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
                    child: Text('Edit'),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      primary: Colors.white,
                    ),
                    child: Text('Save'),
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        String imageName =
                            _item.creationTime.toString() + '_' + _item.userId;
                        Reference ref =
                            FirebaseStorage.instance.ref().child(imageName);
                        if (_image != null) {
                          await ref.putFile(_image);
                        }
                        var url = await ref.getDownloadURL();

                        editItem(
                          widget._itemId,
                          _nameController.text,
                          num.tryParse(_priceController.text),
                          _descriptionController.text,
                          url,
                        );
                        Navigator.pop(context);
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ),
            body: Column(
              children: [
                imageSection(),
                iconSection(),
                textSection(),
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
