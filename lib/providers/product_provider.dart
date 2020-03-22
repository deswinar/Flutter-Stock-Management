import 'package:flutter/material.dart';

class ProductProvider extends ChangeNotifier {
  String id;
  String userId;
  String name;
  String description;
  String qty;

  ProductProvider({
    this.id,
    this.userId,
    this.name,
    this.description,
    this.qty,
  });

  void setName(String name) {
    this.name = name;
    notifyListeners();
  }

  void setDescription(String description) {
    this.description = description;
    notifyListeners();
  }

  void setQty(String qty) {
    this.qty = qty;
    notifyListeners();
  }

  factory ProductProvider.fromMap(Map<String, dynamic> data) {
    return ProductProvider(
      id: data['id'] ?? '',
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      qty: data['qty'] ?? '',
    );
  }

  factory ProductProvider.initialData() {
    return ProductProvider(
      id: '',
      userId: '',
      name: '',
      description: '',
      qty: '',
    );
  }
}