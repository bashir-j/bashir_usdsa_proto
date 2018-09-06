import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'usdsaApp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:usdsa_proto/UserSingleton.dart';

class loginScreen extends StatefulWidget{
  _loginScreenState createState() => new _loginScreenState();
}

class _loginScreenState extends State<loginScreen>{
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  bool isValidEmail(String input) {
    final RegExp regex = new RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
    return regex.hasMatch(input);
  }
//  handleFCM(String userID)async {
//    var tokenDoc = await Firestore.instance
//        .collection('users')
//        .document('FCMTokens')
//        .get();
//    Map<String, dynamic> tokenObj = json.decode(tokenDoc['tokens']);
//    Map<String, dynamic> userData;
//    if(tokenObj[userID] == null){
//      userData[]
//      await Firestore.instance
//          .collection('users')
//          .document(userID)
//          .setData();
//    }
//  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(

      body: new Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          new Container(
              decoration: new BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("images/placeholderSquare.png"),
                    fit: BoxFit.fill
                ),
              ),
          ),
          new Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              new Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 5.0, color: Colors.white),
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
                margin: EdgeInsets.all(8.0),
                child: new Image.asset("images/logo.png"),
              ),
              new Container(
                margin: EdgeInsets.all(8.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: new TextFormField(
                          keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              errorStyle: TextStyle(color: Colors.white, fontSize: 14.0),
                              filled: true,
                              fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                ),
                                hintText: "Email"
                            ),
                            validator: (value){
                              if (value.isEmpty) {
                                return 'Please enter an email';
                              }else if (!isValidEmail(value)) {
                                return 'Please enter a valid email';
                              }
                            },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: new TextFormField(
                          obscureText: true,
                          decoration: InputDecoration(
                              errorStyle: TextStyle(color: Colors.white, fontSize: 14.0),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              ),
                              //labelText: "Password",
                              hintText: "Password"
                          ),
                          validator: (value){
                            if (value.isEmpty) {
                              return 'Please enter a password';
                            }
                          },
                        ),
                      ),
                      ButtonTheme(
                        minWidth: 400.0,
                        child: new RaisedButton(
                          child: new Text("Login"),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                          color: Color(0xFF808188),
                          onPressed: ()async {
                            if(_formKey.currentState.validate()) {
                              final firebaseUser = await FirebaseAuth.instance
                                  .signInWithEmailAndPassword(
                                  email: 'usdsaadmin@yopmail.com',
                                  password: '123456'
                              ).then((user) async {
                                UserSingleton userSing = new UserSingleton();
                                userSing.userID = user.uid;
                                userSing.userEmail = user.email;
                                DocumentSnapshot ds = await Firestore.instance
                                    .collection('users')
                                    .document(user.uid)
                                    .get();
                                userSing.userPriority = ds['priority'];
                                //handleFCM(user.uid);
                                Navigator.pushReplacement(
                                  context,
                                  new MaterialPageRoute(
                                      builder: (context) => new usdsaApp()),
                                );
                              });
                            }
                          }
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ]
        ),
      );
  }

}