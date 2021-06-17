// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:image_picker/image_picker.dart';

// import 'home.dart';
// import 'login.dart';

// class ItemEditPage extends StatefulWidget {
//   final Item item;
//   ItemEditPage({Key key, @required this.item}) : super(key: key);

//   @override
//   _ItemEditPageState createState() => _ItemEditPageState();
// }

// class _ItemEditPageState extends State<ItemEditPage> {
//   File _image;
//   final picker = ImagePicker();
//   final _formKey = GlobalKey<FormState>(debugLabel: '_ItemEditPageState');

//   @override
//   Widget build(BuildContext context) {
//     final _nameController = TextEditingController(text: '${widget.item.name}');
//     final _priceController =
//         TextEditingController(text: '${widget.item.price}');
//     final _descriptionController =
//         TextEditingController(text: '${widget.item.description}');
//     Widget imageSection = Container(
//         child: _image == null
//             ? Image.network(
//                 widget.item.imageURL,
//                 width: 600,
//                 height: 240,
//                 fit: BoxFit.fitWidth,
//               )
//             : Image.file(
//                 _image,
//                 width: 600,
//                 height: 240,
//                 fit: BoxFit.fitWidth,
//               ));
//     Widget iconSection = Row(
//       mainAxisAlignment: MainAxisAlignment.end,
//       children: <Widget>[
//         IconButton(
//             icon: Icon(Icons.photo_camera),
//             onPressed: () {
//               getImage();
//             }),
//       ],
//     );
//     Widget textSection = Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Form(
//         key: _formKey,
//         child: Container(
//           padding: EdgeInsets.only(left: 50.0, right: 50.0),
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: _nameController,
//                 decoration: const InputDecoration(
//                   hintText: 'Product Name',
//                   hintStyle: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Enter product name to continue';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _priceController,
//                 keyboardType: TextInputType.number,
//                 inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                 decoration: const InputDecoration(
//                   hintText: 'Price',
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Enter product price to continue';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _descriptionController,
//                 decoration: const InputDecoration(
//                   hintText: 'Description',
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Enter product description to continue';
//                   }
//                   return null;
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: Row(
//           children: <Widget>[
//             TextButton(
//               style: TextButton.styleFrom(
//                 primary: Colors.white,
//               ),
//               child: Text('Cancel'),
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//             ),
//             Padding(
//               padding: EdgeInsets.only(left: 75.0, right: 100.0),
//               child: Text('Edit'),
//             ),
//             Consumer<ApplicationState>(
//               builder: (context, appState, _) => TextButton(
//                 style: TextButton.styleFrom(
//                   primary: Colors.white,
//                 ),
//                 child: Text('Save'),
//                 onPressed: () async {
//                   if (_formKey.currentState.validate()) {
//                     await appState.editItemFromFirestore(
//                         widget.item.id,
//                         _nameController.text,
//                         num.tryParse(_priceController.text),
//                         _descriptionController.text);
//                     await appState.editImageFromStorage(widget.item.name,
//                         widget.item.imageURL, _nameController.text, _image);
//                   }
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           imageSection,
//           iconSection,
//           textSection,
//         ],
//       ),
//     );
//   }

//   Future getImage() async {
//     final pickedFile = await picker.getImage(source: ImageSource.gallery);

//     setState(() {
//       if (pickedFile != null) {
//         _image = File(pickedFile.path);
//       } else {
//         print('No image selected');
//       }
//     });
//   }
// }
