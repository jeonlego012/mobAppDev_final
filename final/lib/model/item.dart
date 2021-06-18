import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final String id;
  final String userId;
  final String name;
  final int price;
  final String description;
  final String imageURL;
  final Timestamp creationTime;
  final Timestamp updatedTime;
  final List<dynamic> likeUsers;
  final DocumentReference reference;

  Item(
      {this.userId, this.name, this.price, this.description, this.creationTime})
      : id = null,
        imageURL = null,
        updatedTime = null,
        likeUsers = [],
        reference = null;

  Item.fromSnapshot(DocumentSnapshot snapshot)
      : assert(snapshot != null),
        id = snapshot.id,
        userId = snapshot.data()['userId'],
        name = snapshot.data()['name'],
        price = snapshot.data()['price'],
        description = snapshot.data()['description'],
        imageURL = snapshot.data()['imageURL'],
        creationTime = snapshot.data()['creationTime'],
        updatedTime = snapshot.data()['updatedTime'],
        likeUsers = snapshot.data()['likeUsers'],
        reference = snapshot.reference;
}
