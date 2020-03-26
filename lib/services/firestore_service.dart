import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stock_management/models/category.dart';
import 'package:stock_management/models/product.dart';

class FirestoreService {
  final Firestore _db = Firestore.instance;

  // Product

  Stream<List<Product>> getProducts(FirebaseUser user, {sort = null}) {
    var first = sort == null
      ? _db
          .collection('products')
          .document(user.uid)
          .collection('products')
          .orderBy('lastUpdated', descending: true)
          .limit(10)
          .snapshots()
      : _db
          .collection('products')
          .document(user.uid)
          .collection('products')
          .orderBy(sort['sortBy'], descending: sort['isDescending'])
          .limit(10)
          .snapshots();

    return first.map((list) => list.documents.map((doc) => Product.fromFirestore(doc)).toList());
  }

  Stream<List<Product>> getMoreProducts(FirebaseUser user, lastData, {sort = null}) {
    var next = sort == null
      ? _db
          .collection('products')
          .document(user.uid)
          .collection('products')
          .orderBy('lastUpdated', descending: true)
          .limit(10)
          .startAfter(lastData)
          .snapshots()
      : _db
          .collection('products')
          .document(user.uid)
          .collection('products')
          .orderBy(sort['sortBy'], descending: sort['isDescending'])
          .limit(10)
          .startAfter(lastData)
          .snapshots();

    return next.map((list) => list.documents.map((doc) => Product.fromFirestore(doc)).toList());
  }

  Stream<Product> getProduct(FirebaseUser user, String id) {
    return _db
        .collection('products')
        .document(user.uid)
        .collection('products')
        .document(id)
        .snapshots()
        .map((list) => Product.fromMap(list.data));
  }

  Future<void> createProduct(FirebaseUser user, Map data) {
    return _db
        .collection('products')
        .document(user.uid)
        .collection('products')
        .add({
          'name': data['name'] ?? '',
          'description': data['description'] ?? '',
          'qty': data['qty'] ?? '',
          'category': data['category'] ?? '',
          'imageUrl': data['imageUrl'] ?? '',
          'lastUpdated': DateTime.now(),
          'categorySearchList': setSearchParam(data['category'] ?? ''),
        });
  }

  Future<void> deleteProduct(FirebaseUser user, String id) {
    return _db
        .collection('products')
        .document(user.uid)
        .collection('products')
        .document(id)
        .delete();
  }

  Future<void> updateProduct(FirebaseUser user, Map data) {
    return _db
      .collection('products')
      .document(user.uid)
      .collection('products')
      .document(data['id'])
      .updateData({
        'name': data['name'] ?? '',
        'description': data['description'] ?? '',
        'qty': data['qty'] ?? '',
        'category': data['category'] ?? '',
        'imageUrl': data['imageUrl'] ?? '',
        'lastUpdated': DateTime.now(),
        'categorySearchList': setSearchParam(data['category'] ?? ''),
      });
  }


  // Category

  Stream<List<Category>> getCategories(FirebaseUser user) {
    var ref = _db.collection('products').document(user.uid).collection('categories').snapshots();
    return ref.map((list) => list.documents.map((doc) => Category.fromFirestore(doc)).toList());
  }

  Stream<List<Category>> getCategorySuggestions(FirebaseUser user) {
    var ref = _db
      .collection('products')
      .document(user.uid)
      .collection('products')
      .snapshots();
      return ref.map((list) => list.documents.map((doc) => Category.fromFirestore(doc)).toList());
  }

  List<String> setSearchParam(String caseText) {
    List<String> caseSearchList = List();
    String temp = "";
    for (int i = 0; i < caseText.length; i++) {
      temp = temp + caseText[i];
      caseSearchList.add(temp);
    }
    return caseSearchList;
  }
}