import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gmailverification/constants/strings.dart';

class AuthMethods{
  static final Firestore _firestore =Firestore.instance;
  final FirebaseAuth _auth =FirebaseAuth.instance;

  String name;
  String email;
  String password;


  void addConnectedUser(String email, String password) async{
    FirebaseUser firebaseUser =(await _auth.signInWithEmailAndPassword(email: email, password: password)).user;
    if(firebaseUser != null){
      //check is already sign in
      final QuerySnapshot result = await Firestore.instance.collection(USERS_COLLECTION)
          .where(USERS_ID,isEqualTo: firebaseUser.uid).getDocuments();
      final List<DocumentSnapshot> documents =result.documents;
      if(documents.length ==0){
        _firestore.collection(USERS_COLLECTION).document(firebaseUser.uid).setData({
          'email':email,
          'id':firebaseUser.uid,
          'nickname':name,
        });
      }
    }

  }
  void verifyEmail(FirebaseUser user) async{
    try{
      await user.sendEmailVerification();
      Fluttertoast.showToast(msg: "Sending email verification");
    }catch(e){
      print('An error occured while trying to send email verification');
      print(e.message);
    }
  }


  void createUser(String email, String password) async{
    await _auth.createUserWithEmailAndPassword(email: email, password: password).then((onvalue){
      verifyEmail(onvalue.user);
      addConnectedUser(email, password);

    }).catchError((onError){
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
  


}