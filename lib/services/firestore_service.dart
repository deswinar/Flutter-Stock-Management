import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stock_management/models/category.dart';
import 'package:stock_management/models/product.dart';
import 'package:stock_management/providers/product_provider.dart';

class FirestoreService {
  final Firestore _db = Firestore.instance;

  // Product

  Stream<List<Product>> getProducts(FirebaseUser user) {
    var first = _db.collection('products')
      .where('userId', isEqualTo: user.uid)
      .orderBy('lastUpdated')
      .limit(10)
      .snapshots();

    return first.map((list) => list.documents.map((doc) => Product.fromFirestore(doc)).toList());
  }

  Stream<List<Product>> getMoreProducts(FirebaseUser user, lastData) {
    var next = _db.collection('products')
      .where('userId', isEqualTo: user.uid)
      .orderBy('lastUpdated')
      .limit(10)
      .startAfter(lastData)
      .snapshots();

    return next.map((list) => list.documents.map((doc) => Product.fromFirestore(doc)).toList());
  }

  Stream<ProductProvider> getProduct(String id) {
    return _db
        .collection('products')
        .document(id)
        .snapshots()
        .map((list) => ProductProvider.fromMap(list.data));
  }

  Future<void> createProduct(FirebaseUser user, Map data) {
    return _db
        .collection('products')
        .add({
          'userId': user.uid,
          'name': data['name'] ?? '',
          'description': data['description'] ?? '',
          'qty': data['qty'] ?? '',
          'category': data['category'] ?? '',
          'imageUrl': data['imageUrl'] ?? '',
          'lastUpdated': DateTime.now(),
        });
  }

  Future<void> updateProduct(String id, data) {
    return _db.collection('products').document(id).updateData(data);
  }


  // Category

  Stream<List<Category>> getCategories(FirebaseUser user) {
    var ref = _db.collection('categories').document(user.uid).collection('list').snapshots();
    return ref.map((list) => list.documents.map((doc) => Category.fromFirestore(doc)).toList());
  }

  Future<void> createCategory(FirebaseUser user, Map data) {
    return _db
        .collection('categories')
        .document(user.uid)
        .collection('list')
        .add({
          'category': data['category'] ?? '',
        });
  }
}