import 'package:flutter/material.dart';

class StockProvider extends ChangeNotifier {
  String name;
  String description;
  String qty;

  void setName(String name) {
    this.name = name;
    notifyListeners();
  }

  void setDescription(String description) {
    this.description = description;
    notifyListeners();
  }

  void setQty(String qty)
}