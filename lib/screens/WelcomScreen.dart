import 'package:flutter/material.dart';
import 'package:gmailverification/screens/register_screen.dart';

class WelcomeScreen extends StatefulWidget {
  static String id= 'welcome_screen';
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: RaisedButton(
            child: Text('next'),
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(
                builder: (context) =>RegistrationScreen()
              ));
            },
          ),
        ),
    );
  }
}
