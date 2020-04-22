import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'login_screen.dart';



final  _firestore = Firestore.instance;

class RegistrationScreen extends StatefulWidget {
  static String id= 'registration_screen';

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth=FirebaseAuth.instance;
  bool showSpinner = false;
  String name;
  String email;
  String password;

  void addConnectedUser(String email , String  password ) async{
    FirebaseUser firebaseUser = (await _auth.signInWithEmailAndPassword(email: email,
        password: password)).user;
    if(firebaseUser != null) {
      // Check is already sign in
      final QuerySnapshot result =
      await Firestore.instance.collection('users').where(
          'id', isEqualTo: firebaseUser.uid).getDocuments();
      final List < DocumentSnapshot > documents = result.documents;
      if (documents.length == 0) {
        // Update data to server if new user
        _firestore.collection('users').document(firebaseUser.uid).setData(
            { 'email': email,'id': firebaseUser.uid , 'nickname': name,'age':'','about':'','pic_url':''});



      }
    }
  }

  void verifyEmail(FirebaseUser user) async{

    try {
      await user.sendEmailVerification();
      Fluttertoast.showToast(msg: "sending email verification");

    } catch (e) {
      print("An error occured while trying to send email        verification");
      print(e.message);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Flexible(
                      child: Hero(
                        tag: 'logo',
                        child: Container(
                          height: 200.0,
                          child:Text('image'),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 48.0,
                    ),
                    TextField(
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.text,
                      onChanged: (value) {
                        //Do something with the user input.
                        name=value;
                      },
                      decoration: KInputTextFieldDecoration.copyWith(
                        hintText: 'Enter your nickname',

                      ),),
                    SizedBox(
                      height: 8.0,
                    ),
                    TextField(
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          //Do something with the user input.
                          email=value;
                        },
                        decoration: KInputTextFieldDecoration.copyWith(
                          hintText: 'Enter your email',

                        )
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    TextField(
                        textAlign: TextAlign.center,
                        obscureText: true,
                        onChanged: (value) {
                          //Do something with the user input.
                          password = value;
                        },
                        decoration: KInputTextFieldDecoration.copyWith(
                          hintText: 'Enter your password',

                        )
                    ),
                    SizedBox(
                      height: 24.0,
                    ),
                    RaisedButton(color: Colors.black,
                      child: Text('register'),
                      onPressed: () async{
                        setState(() {
                          showSpinner = true;
                        });
                        /*register user*/
                        await _auth.createUserWithEmailAndPassword(
                            email: email, password: password).then((onValue){
                          verifyEmail(onValue.user);
                          addConnectedUser(email,password);
                          Navigator.pushNamed(context, LoginScreen.id);


                          setState(() {
                            showSpinner = false;
                          });


                        }).catchError((onError){
                          setState(() {
                            showSpinner = false;
                          });
                          print(onError.toString());

                          if(onError.toString().contains("ERROR_EMAIL_ALREADY_IN_USE")){
                            Fluttertoast.showToast(msg: "The email address is already in use by another account");
                          } else
                          if(onError.toString().contains("ERROR_NETWORK_REQUEST_FAILED")){
                            Fluttertoast.showToast(msg: "check out your network");
                          }else if(onError.toString().contains("ERROR_INVALID_EMAIL")){
                            Fluttertoast.showToast(msg: "The email address is badly formatted");
                          }else{
                            Fluttertoast.showToast(msg: onError.toString());
                          }

                        });
                      }
                      ),
                  ]
              )),
        ));
  }
}


const KInputTextFieldDecoration =InputDecoration(
  labelStyle: TextStyle(color: Colors.black),
  hintStyle: TextStyle(color: Colors.grey),
  contentPadding:
  EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.black, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.black, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);
