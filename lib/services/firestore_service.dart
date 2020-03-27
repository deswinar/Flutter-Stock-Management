import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stock_management/models/category.dart';
import 'package:stock_management/models/product.dart';

class FirestoreService {
  final Firestore _db = Firestore.instance;

  // Product

  Stream<List<Product>> getProducts(FirebaseUser user, {sort = null, search = ""}) {
    var first = _db
        .collection('products')
        .where('userId', isEqualTo: user.uid)
        .orderBy(sort == null ? 'lastUpdated' : sort['sortBy'], descending: sort == null ? true : sort['isDescending'])
        .limit(10);

    var res = search == ""
      ? first.snapshots()
      : first.where('nameSearchList', arrayContains: search.toLowerCase()).snapshots();

    return res.map((list) => list.documents.map((doc) => Product.fromFirestore(doc)).toList());
  }

  Stream<List<Product>> getMoreProducts(FirebaseUser user, lastData, {sort = null, search = ""}) {
    var next = _db
          .collection('products')
          .where('userId', isEqualTo: user.uid)
          .orderBy(sort == null ? 'lastUpdated' : sort['sortBy'], descending: sort == null ? true : sort['isDescending'])
          .limit(10)
          .startAfter(lastData);

    var res = search == ""
      ? next.snapshots()
      : next.where('nameSearchList', arrayContains: search.toLowerCase()).snapshots();

    return res.map((list) => list.documents.map((doc) => Product.fromFirestore(doc)).toList());
  }

  Future<List<Product>> getProductsFuture(FirebaseUser user, {sort = null}) async {
    var first = sort == null
      ? await _db
          .collection('products')
          .where('userId', isEqualTo: user.uid)
          .orderBy('lastUpdated', descending: true)
          .limit(10)
          .getDocuments()
      : await _db
          .collection('products')
          .where('userId', isEqualTo: user.uid)
          .orderBy(sort['sortBy'], descending: sort['isDescending'])
          .limit(10)
          .getDocuments();

      return first.documents.map((doc) => Product.fromMap(doc.data)).toList();
  }

  // Future<List<Product>> fetchProducts(FirebaseUser user, {sort = null}) async {
  //   var result = await getProductsCollection(user, sort: sort);
  //   var products = result.documents
  //       .map((doc) => Product.fromMap(doc.data))
  //       .toList();
  //   return products;
  // }

  Stream<Product> getProduct(FirebaseUser user, String id) {
    return _db
        .collection('products')
        .document(id)
        .snapshots()
        .map((list) => Product.fromMap(list.data));
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
          'categorySearchList': setSearchParam(data['category'] ?? ''),
          'nameSearchList': setSearchParam(data['name'] ?? ''),
        });
  }

  Future<void> deleteProduct(FirebaseUser user, String id) {
    return _db
        .collection('products')
        .document(id)
        .delete();
  }

  Future<void> updateProduct(FirebaseUser user, Map data) {
    return _db
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
        'nameSearchList': setSearchParam(data['name'] ?? ''),
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
      .where('userId', isEqualTo: user.uid)
      .snapshots();
      return ref.map((list) => list.documents.map((doc) => Category.fromFirestore(doc)).toList());
  }

  List<String> setSearchParam(String caseText) {
    List<String> caseSearchList = List();
    var splitCaseText = caseText.split(" ");
    String temp = "";
    splitCaseText.forEach((text) {
      for (int i = 0; i < text.length; i++) {
        temp = temp + text[i].toLowerCase();
        caseSearchList.add(temp);
      }
      temp = "";
    });
    return caseSearchList;
  }
}