

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:usdsa_proto/EnsureVisWhileFocused.dart';

class CreateNewAccountPage extends StatefulWidget{
  @override
  _CreateNewAccountPageState createState() => new _CreateNewAccountPageState();
}

class _CreateNewAccountPageState extends State<CreateNewAccountPage>{
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  TextEditingController passcont = new TextEditingController();
  FocusNode _focusNodeFName = new FocusNode();
  FocusNode _focusNodeLName = new FocusNode();
  FocusNode _focusNodeEmail = new FocusNode();
  FocusNode _focusNodePassPrim = new FocusNode();
  FocusNode _focusNodePassSec = new FocusNode();

  bool isValidEmail(String input) {
    final RegExp regex = new RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return regex.hasMatch(input);
  }
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle titleStyle = theme.textTheme.headline.copyWith(color: Colors.black);
    final TextStyle subStyle = theme.textTheme.body1.copyWith(fontSize: 22.0);

    String fname;
    String lname;
    String email;
    String pass;
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: new Scaffold(
        appBar: new AppBar(
          title: Text("Create New Account"),
        ),
        body: new SafeArea(
            top: false,
            bottom: false,
            child: new Container(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                autovalidate: false,
                child: new ListView(
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: EnsureVisibleWhenFocused(
                        focusNode: _focusNodeFName,
                        child: new TextFormField(
                          focusNode: _focusNodeFName,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              ),
                              labelStyle: titleStyle,
                              labelText: "First Name",
                              hintText: "Enter First Name Here"
                          ),
                          validator: (value){
                            if (value.isEmpty) {
                              return 'Please enter some text';
                            }
                          },
                          onSaved: (value){
                            fname = value;
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: EnsureVisibleWhenFocused(
                        focusNode: _focusNodeLName,
                        child: new TextFormField(
                          focusNode: _focusNodeLName,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              ),
                              labelStyle: titleStyle,
                              labelText: "Last Name",
                              hintText: "Enter Last Name Here"
                          ),
                          validator: (value){
                            if (value.isEmpty) {
                              return 'Please enter some text';
                            }
                          },
                          onSaved: (value){
                            lname = value;
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: EnsureVisibleWhenFocused(
                        focusNode: _focusNodeEmail,
                        child: new TextFormField(
                          focusNode: _focusNodeEmail,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              ),
                              labelStyle: titleStyle,
                              labelText: "Email",
                              hintText: "Enter Email Here"
                          ),
                          validator: (value){
                            if (value.isEmpty) {
                              return 'Please enter an email';
                            }else if (!isValidEmail(value)) {
                              return 'Please enter a valid email';
                            }
                          },
                          onSaved: (value){
                            email = value;
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: EnsureVisibleWhenFocused(
                        focusNode: _focusNodePassPrim,
                        child: new TextFormField(
                          controller: passcont,
                          focusNode: _focusNodePassPrim,
                          obscureText: true,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              ),
                              labelStyle: titleStyle,
                              labelText: "Password",
                              hintText: "Enter Password Here"
                          ),
                          validator: (value){
                            if (value.isEmpty) {
                              return 'Please enter a password';
                            }else if (value.length < 6) {
                              return 'Please enter a password longer than 6 characters';
                            }
                          },
                          onSaved: (value){
                            pass = value;
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: EnsureVisibleWhenFocused(
                        focusNode: _focusNodePassSec,
                        child: new TextFormField(
                          focusNode: _focusNodePassSec,
                          obscureText: true,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              ),
                              labelStyle: titleStyle,
                              labelText: "Confirm Password",
                              hintText: "Re-enter Password Here"
                          ),
                          validator: (value){
                            if (value.isEmpty) {
                              return 'Please enter a password';
                            }else if (value.length < 6) {
                              return 'Please enter a password longer than 6 characters';
                            }
                            else if (value != passcont.value.text) {
                              return 'Passwords don\'t match';
                            }
                          },
                          onSaved: (value){
                            pass = value;
                          },
                        ),
                      ),
                    ),
                    new RaisedButton(
                        child: new Text("Submit"),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                        onPressed: ()async {
                          final FormState form = _formKey.currentState;
                          if(form.validate()) {
                            showDialog(context: context,
                                barrierDismissible: false,
                                builder: (context){
                                  return Center(
                                    child: Container(child: new CircularProgressIndicator()
                                    ),
                                  );
                                }
                            );
                            form.save();
                            FirebaseAuth.instance.createUserWithEmailAndPassword(
                                email: email,
                                password: pass
                            ).then((newUser) async{
                              print("success");
                              Map<String, dynamic> data = new Map<String, dynamic>();
                              data['fname'] = fname;
                              data['email'] = email;
                              data['lname'] = lname;
                              data['priority'] = '0';
                              data['enabled'] = false;
                              data['rCommittees'] = new List<String>();
                              await Firestore.instance.collection('users').document(newUser.uid).setData(data);
                              Navigator.pop(context);
                              Navigator.pop(context);
                              FirebaseAuth.instance.signOut();
                            }).catchError((error){
                              buildDialog("Error Creating Account", error.message);
                            });
                          }
                        }
                    )
                  ],
                ),
              ),
            )
        ),
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
              Navigator.pop(context);
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
                Navigator.pop(context);
              },
            ),
          ],
        );

      }
    });

  }


}