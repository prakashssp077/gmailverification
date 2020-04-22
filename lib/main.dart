import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gmailverification/resources/connectivity.dart';
import 'package:gmailverification/screens/ChatScreen.dart';
import 'package:gmailverification/screens/WelcomScreen.dart';
import 'package:gmailverification/screens/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
void main() {
  ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
  connectionStatus.initialize();
  runApp(MyApp());
}
class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _auth=FirebaseAuth.instance;
  bool logged = false;



  //get current user
  Future<FirebaseUser> getCurrentUser() async{
    FirebaseUser loggedUser;
    try{
      final user = await _auth.currentUser();
      if(user != null){
        loggedUser =  user;
      }}catch(e){
      print(e);
    }
    return loggedUser;
  }

  //check if already user has logged in
  Future<bool> isLoggedIn() async{
    bool check=false;
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String _userUid;

    _userUid = (_prefs.getString('user_id') ?? '');

    final _user =  await getCurrentUser();

    if(_user != null) {
      if (_userUid == _user.uid) {
        check = true;
      }
    }
    return check;
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isLoggedIn(),
      builder: (BuildContext context,AsyncSnapshot<bool> snapshot){
        switch(snapshot.connectionState){
          case ConnectionState.waiting:
            return Container(
              color: Colors.white,
              child: Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  )
              ),
            );
          default:
            if(snapshot.hasError){
              return Text('Error: ${snapshot.error}');
            }else{
              logged = snapshot.data;
              return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  theme: ThemeData(

                    cursorColor: Colors.black,
                    iconTheme: IconThemeData(
                        color: Colors.black
                    ),
                    appBarTheme:AppBarTheme(
                        elevation: 15.0,
                        color: Colors.white,
                        iconTheme: IconThemeData(
                            color: Colors.blueGrey
                        ),
                        actionsIconTheme: IconThemeData(
                            color: Colors.blueGrey
                        ) ,
                        textTheme: TextTheme(
                          title: TextStyle(color: Colors.blueGrey,
                              fontWeight: FontWeight.bold,
                              fontSize: 25.0),
                        )
                    ),

                    textTheme: TextTheme(
                      //body1: TextStyle(color: Colors.lightBlueAccent),
                    ),

                  ),
                  initialRoute: logged == true ? ChatScreen.id : WelcomeScreen.id,
                  routes: {
                    WelcomeScreen.id: (context) => WelcomeScreen(),
                   // LoginScreen.id: (context) => LoginScreen(),
                    RegistrationScreen.id: (context) => RegistrationScreen(),
                    ChatScreen.id: (context) => ChatScreen(),
                   // OnlineScreen.id: (context) => OnlineScreen(),



                  }
              );
            }
        }
      },
    );
  }
}
