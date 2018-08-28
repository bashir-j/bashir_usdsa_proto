import 'package:flutter/material.dart';
import 'usdsaApp.dart';
import 'package:firebase_auth/firebase_auth.dart';

class loginScreen extends StatefulWidget{
  _loginScreenState createState() => new _loginScreenState();
}

class _loginScreenState extends State<loginScreen>{
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
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: new TextFormField(
                        keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              ),
                              hintText: "Email"
                          )
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: new TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                            ),
                            //labelText: "Password",
                            hintText: "Password"
                        ),
                      ),
                    ),
                    ButtonTheme(
                      minWidth: 400.0,
                      child: new RaisedButton(
                        child: new Text("Login"),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                        color: Color(0xFF808188),
                        onPressed: ()async {
                          final firebaseUser = await FirebaseAuth.instance.signInWithEmailAndPassword(
                              email: 'usdsaadmin@yopmail.com',
                              password: '123456'
                          ).whenComplete((){
                            Navigator.push(
                              context,
                              new MaterialPageRoute(builder: (context) => new usdsaApp()),
                            );
                          });



                        }
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ]
        ),
      );
  }

}