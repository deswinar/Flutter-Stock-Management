import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_management/screens/login_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [

      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: LoginScreen.routeName,
        routes: <String, WidgetBuilder>{
          LoginScreen.routeName: (context) => LoginScreen(),
        },
      ),
    );
  }
}