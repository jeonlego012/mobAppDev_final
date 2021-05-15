import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';

import 'login.dart';

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
              print('photo select!');
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
              padding: EdgeInsets.only(left: 90.0, right: 100.0),
              child: Text('Add'),
            ),
            Consumer<ApplicationState>(
              builder: (context, appState, _) => TextButton(
                style: TextButton.styleFrom(
                  primary: Colors.white,
                ),
                child: Text('Save'),
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    await appState.addItemToFirestore(
                        _nameController.text,
                        num.tryParse(_priceController.text),
                        _descriptionController.text);
                    await appState.addImageToStorage(
                        _nameController.text, _image);
                  }
                },
              ),
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
        //print(pickedFile.path);
      } else {
        print('No image selected');
      }
    });
  }

  // void uploadImage(File file, String name) async {
  //   // await firebase_storage.FirebaseStorage.instance
  //   //     .ref(_nameController.text)
  //   //     .putFile(_image)
  //   //     .then((value) => Navigator.pop(context));
  //   firebase_storage.Reference storageReference =
  //       firebase_storage.FirebaseStorage.instance.ref(name);
  //   firebase_storage.UploadTask storageUploadTask =
  //       storageReference.putFile(file);

  //   String imageURL = await storageReference.getDownloadURL();
  // }
}
