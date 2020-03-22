import 'package:flutter/material.dart';
import 'package:stock_management/services/firebase_auth_service.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: name == null ? Text('null') : Text(name),
    );
  }

}