import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usdsa_proto/GroupItem.dart';
import 'package:usdsa_proto/pages/CreateNewAccount.dart';
import 'usdsaApp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:usdsa_proto/UserSingleton.dart';
import 'package:cloud_functions/cloud_functions.dart';

class loginScreen extends StatefulWidget{
  _loginScreenState createState() => new _loginScreenState();
}

class _loginScreenState extends State<loginScreen>{
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  bool authed;
  String spEmail;
  String spPass;
  bool checking;
  bool isValidEmail(String input) {
    final RegExp regex = new RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
    return regex.hasMatch(input);
  }
  @override
  void initState() {
    checking = true;
    SharedPreferences.getInstance().then((prefs){
      authed = prefs.getBool('authed');
      spEmail = prefs.getString('email');
      spPass = prefs.getString('pass');
      print('got');
      print('authed: ' + authed.toString());
      if(authed != null && authed){
        FirebaseAuth.instance
            .signInWithEmailAndPassword(
          email: spEmail,
          password: spPass,
        ).then((user) async {
          UserSingleton userSing = new UserSingleton();
          userSing.userID = user.uid;
          userSing.userEmail = user.email;
          DocumentSnapshot ds = await Firestore.instance
              .collection('users')
              .document(user.uid)
              .get();
          userSing.userPriority = ds['priority'];
          userSing.userFName = ds['fname'];
          userSing.userLName = ds['lname'];
          userSing.userCommittees = new List<String>.from(ds['rCommittees']);
          //handleFCM(user.uid);
          List<String> topics = new List<String>();
          topics.add("/topics/announcements");
          prefs.setStringList('topics', topics);
          Navigator.pushReplacement(
            context,
            new MaterialPageRoute(
                builder: (context) => new usdsaApp()),
          );
          userSing.userCommitteesItems = new List<GroupItem>();
          userSing.userCommittees.forEach((cName)async {
            DocumentSnapshot cds = await Firestore.instance
                .collection('committees')
                .document(cName)
                .get();
            List<String> jUsers = new List<String>.from(cds['jUsers']);
            userSing.userCommitteesItems.add(
                new GroupItem(
                  groupName: cds['name'],
                  description: cds['description'],
                  groupIconURL: cds['iconUrl'],
                  password: cds['password'],
                  jUsers: jUsers,
                )
            );
          });
        });
      }
      else{
        setState(() {
          checking = false;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String entEmail;
    String entPass;
    print('authed: ' + authed.toString());
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
          new ListView(
//            crossAxisAlignment: CrossAxisAlignment.center,
//            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              new Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 5.0, color: Colors.white),
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
                margin: EdgeInsets.all(8.0),
                child: new Image.asset("images/logo.png"),
              ),
              (!checking) ? new Container(
                margin: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0, top: 128.0),
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
                          onSaved: (value){
                            entEmail = value;
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
                          onSaved: (value){
                            entPass = value;
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
                              showDialog(context: context,
                                  barrierDismissible: false,
                                  builder: (context){
                                    return Center(
                                      child: Container(child: new CircularProgressIndicator()
                                      ),
                                    );
                                  }
                              );
                              _formKey.currentState.save();
                              final firebaseUser = await FirebaseAuth.instance
                                  .signInWithEmailAndPassword(
                                  email: entEmail,
                                  password: entPass
                              ).then((user) async {
                                UserSingleton userSing = new UserSingleton();
                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                prefs.setBool('authed', true);
                                prefs.setString('email', entEmail);
                                prefs.setString('pass', entPass);
                                userSing.userID = user.uid;
                                userSing.userEmail = user.email;
                                DocumentSnapshot ds = await Firestore.instance
                                    .collection('users')
                                    .document(user.uid)
                                    .get();
                                userSing.userPriority = ds['priority'];
                                userSing.userFName = ds['fname'];
                                userSing.userLName = ds['lname'];
                                userSing.userCommittees = new List<String>.from(ds['rCommittees']);
                                //handleFCM(user.uid);
                                Navigator.pop(context);
                                Navigator.pushReplacement(
                                  context,
                                  new MaterialPageRoute(
                                      builder: (context) => new usdsaApp()),
                                );
                                userSing.userCommitteesItems = new List<GroupItem>();
                                userSing.userCommittees.forEach((cName)async {
                                  DocumentSnapshot cds = await Firestore.instance
                                      .collection('committees')
                                      .document(cName)
                                      .get();
                                  List<String> jUsers = new List<String>.from(cds['jUsers']);
                                  userSing.userCommitteesItems.add(
                                    new GroupItem(
                                      groupName: cds['name'],
                                      description: cds['description'],
                                      groupIconURL: cds['iconUrl'],
                                      password: cds['password'],
                                      jUsers: jUsers,
                                    )
                                  );
                                });
                              }).catchError((error){
                                Navigator.pop(context);
                                print(error);
                                PlatformException er = error;
                                if(er.message.contains("password is invalid")){
                                  buildDialog("Incorrect Password", "The password is incorrect, please re-enter it & try again");
                                }
                                else if(er.message.contains("is no user record corresponding")){
                                  buildDialog("Invalid User", "The email entered is incorrect, please re-enter it & try again");
                                }
                                else if(er.message.contains("network error")){
                                  buildDialog("Network Error", "A network error occured, please check your connection & try again");
                                }
                                else if(er.message.contains("user account has been")){
                                  buildDialog("Account Not Yet Enabled", "Your account has not yet been enabled. Please contact an admin to enable your account");
                                }
                                else{
                                  print(er.message);
                                }
                              });
                            }
                          }
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: GestureDetector(
                          onTap: (){
                            Navigator.push(
                              context,
                              new MaterialPageRoute(builder: (context) => new CreateNewAccountPage()),
                            );
                          },
                          child: new Text("New User? Create New Account",
                            style: TextStyle(color: Colors.white, fontSize: 22.0, decoration: TextDecoration.underline),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: new Text("Forgot Password?",
                          style: TextStyle(color: Colors.white, fontSize: 22.0, decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                ),
              ) :
              Center(child: Padding(
                padding: const EdgeInsets.only(top: 128.0),
                child: new CircularProgressIndicator(),
              )),
            ],
          ),
        ]
        ),
      );
  }

  buildDialog(String title, String desc){
    final ios = Theme.of(context).platform == TargetPlatform.iOS;
    showDialog(context: context, builder: (BuildContext context){
      if(!ios){
        return new AlertDialog(
          title: new Text(title),
          content: new Text(desc),
          actions: <Widget>[
            new FlatButton(onPressed: (){
              Navigator.of(context).pop();
            },
                child: new Text("Okay")
            ),
          ],
        );
      }else{
        return new CupertinoAlertDialog(
          title: new Text(title),
          content: new Text(desc),
          actions: <Widget>[
            new CupertinoDialogAction(
              child: new Text("Okay"),
              onPressed: (){
                Navigator.of(context).pop();
              },
            ),
          ],
        );

      }
    });

  }


}