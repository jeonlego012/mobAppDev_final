import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'item.dart';

Future<void> addItem(Item item, File image) async {
  final items = FirebaseFirestore.instance.collection('items');
  String imageName =
      item.creationTime.toString() + '_' + item.userId.toString();
  Reference ref = FirebaseStorage.instance.ref().child(imageName);
  await ref.putFile(image);
  var url = await ref.getDownloadURL();
  return items.add({
    'userId': item.userId,
    'name': item.name,
    'price': item.price,
    'description': item.description,
    'imageURL': url,
    'creationTime': item.creationTime,
    'updatedTime': item.updatedTime,
    'likeUsers': item.likeUsers,
  });
}

Future<void> editItem(String itemId, String name, int price, String description,
    String imageURL) {
  final firebase_item =
      FirebaseFirestore.instance.collection('items').doc(itemId);
  return firebase_item.update({
    'name': name,
    'price': price,
    'description': description,
    'imageURL': imageURL,
    'updatedTime': Timestamp.now(),
  });
}

Future<void> deleteItem(String itemId) async {
  final firebase_item =
      FirebaseFirestore.instance.collection('items').doc(itemId);
  final storage_item = FirebaseStorage.instance;
  String itemCreationTime, itemUserId, imageName;
  firebase_item.get().then((value) {
    itemCreationTime = value.data()['creationTime'].toString();
    itemUserId = value.data()['userId'];
    imageName = itemCreationTime + '_' + itemUserId;
    storage_item
        .ref(imageName)
        .delete()
        .then((value) => firebase_item.delete());
  });
}

Stream<QuerySnapshot> loadAllItems() {
  return FirebaseFirestore.instance
      .collection('items')
      .orderBy('price', descending: true)
      .snapshots();
}

List<Item> getItemsFromQuery(QuerySnapshot snapshot) {
  return snapshot.docs.map((DocumentSnapshot doc) {
    return Item.fromSnapshot(doc);
  }).toList();
}

Future<Item> getItem(String itemId) async {
  return FirebaseFirestore.instance
      .collection('items')
      .doc(itemId)
      .get()
      .then((DocumentSnapshot doc) => Item.fromSnapshot(doc));
}
