import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  String id;
  String category;

  Category({this.id, this.category});

  factory Category.fromMap(Map data) {
    return Category(
      id: data['id'] ?? '',
      category: data['category'] ?? '',
    );
  }

  factory Category.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;
    return Category(
      id: doc.documentID,
      category: data['category'] ?? '',
    );
  }
}