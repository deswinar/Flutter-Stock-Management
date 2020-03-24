import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_management/models/category.dart';
import 'package:stock_management/screens/add_product_screen.dart';
import 'package:stock_management/screens/edit_product_screen.dart';
import 'package:stock_management/screens/home_screen.dart';
import 'package:stock_management/screens/login_screen.dart';
import 'package:stock_management/screens/sort_product_screen.dart';
import 'package:stock_management/services/firestore_service.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<FirebaseUser>(create: (context) => FirebaseAuth.instance.onAuthStateChanged),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: LoginScreen.routeName,
        routes: <String, WidgetBuilder>{
          LoginScreen.routeName: (context) => LoginScreen(),
          HomeScreen.routeName: (context) => HomeScreen(),
          AddProductScreen.routeName: (context) => AddProductScreenRoute(isCreate: true,),
          EditProductScreen.routeName: (context) => AddProductScreenRoute(isCreate: false,),
          SortProductScreen.routeName: (context) => SortProductScreen(),
        },
      ),
    );
  }
}

class AddProductScreenRoute extends StatelessWidget {
  final db = FirestoreService();
  final bool isCreate;

  AddProductScreenRoute({this.isCreate});

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<FirebaseUser>(context);
    return StreamProvider<List<Category>>.value(
      value: db.getCategories(user),
      child: isCreate == true ? AddProductScreen() : EditProductScreen(),
    );
  }
}