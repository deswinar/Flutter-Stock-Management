import 'package:flutter/material.dart';
import 'package:stock_management/screens/home_screen.dart';
import 'package:stock_management/services/firebase_auth_service.dart';

class LoginScreen extends StatefulWidget {
  static final routeName = '/login';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('assets/icons/app_logo.png', width: 150, height: 150,),
              SizedBox(height: 50.0,),
              _signInButton(context, _scaffoldKey),
            ],
          ),
        )
      ),
    );
  }
}

Widget _signInButton(context, scaffoldKey) {
  return OutlineButton(
    splashColor: Colors.blue,
    onPressed: () {
      scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Row(
            children: <Widget>[
              CircularProgressIndicator(),
              Text("Signing in...")
            ],
          ),
        )
      );
      signInWithGoogle().whenComplete(() {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) {
              return HomeScreen();
            },
          ),
        );
      });
    },
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
    highlightElevation: 0,
    borderSide: BorderSide(color: Colors.grey),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image(image: AssetImage("assets/icons/google_logo.png"), height: 28.0),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              'Sign in with Google',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          )
        ],
      ),
    ),
  );
}

class Consts {
  Consts._();

  static const double margin = 24.0;
  static const double padding = 16.0;
  static const double avatarRadius = 64.0;
}