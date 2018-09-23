

import 'package:flutter/material.dart';
import 'package:usdsa_proto/UserSingleton.dart';
import 'package:usdsa_proto/pages/ApproveUsersPage.dart';

class SettingPage extends StatefulWidget{
  _settingsPageState createState() => new _settingsPageState();
}

class _settingsPageState extends State<SettingPage>{
  @override
  Widget build(BuildContext context) {
    UserSingleton userSing = new UserSingleton();
    final ThemeData theme = Theme.of(context);
    final TextStyle titleStyle = theme.textTheme.headline.copyWith(color: Colors.black, fontSize: 32.0);
    final TextStyle descriptionStyle = theme.textTheme.subhead.copyWith(fontSize: 24.0);
    return new SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 48.0),
                  //padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0),
                  decoration: BoxDecoration(
                    border: new Border.all(color: Colors.black54, width: 2.0),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  child: Column(
                    children: <Widget>[
                      new ListTile(
                        title: new Text("Name", style: TextStyle(fontSize: 20.0),),
                        subtitle: new Text(userSing.userFName + ' ' + userSing.userLName),
                      ),
                      new ListTile(
                        title: new Text("Email", style: TextStyle(fontSize: 20.0),),
                        subtitle: new Text(userSing.userEmail),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 32.0, top: 20.0),
                  decoration: BoxDecoration(color: theme.scaffoldBackgroundColor),
                    //padding: EdgeInsets.only(left: 64.0, top: 4.0),
                    child: new Text("User Details", style: titleStyle,)
                ),
              ],
            ),
            userSing.userPriority == '2' ?
            Stack(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 48.0),
                  //padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0),
                  decoration: BoxDecoration(
                    border: new Border.all(color: Colors.black54, width: 2.0),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  child: Column(
                    children: <Widget>[
                      new ListTile(leading: Icon(Icons.group_add),title: Text("Approve Users"), onTap: (){
                        Navigator.push(
                          context,
                          new MaterialPageRoute(builder: (context) => new ApproveUsersPage()),
                        );
                      },
                        trailing: Icon(Icons.chevron_right),
                      )
                    ],
                  ),
                ),
                Container(
                    margin: EdgeInsets.only(left: 32.0, top: 20.0),
                    decoration: BoxDecoration(color: theme.scaffoldBackgroundColor),
                    //padding: EdgeInsets.only(left: 64.0, top: 4.0),
                    child: new Text("User Management", style: titleStyle,)
                ),
              ],
            ) : new Container(),

          ],
        )
//        Column(
//          children: <Widget>[
//            new Container(
//              padding: EdgeInsets.all(16.0),
//              child: Column(
//                crossAxisAlignment: CrossAxisAlignment.start,
//                children: <Widget>[
//                  Container(
//                    padding: EdgeInsets.only(bottom: 4.0),
//                    child: new Text("Name", style: titleStyle,),
//                  ),
//                  Container(
//                    padding: EdgeInsets.only(bottom: 16.0),
//                    child: new Row(
//                      mainAxisAlignment: MainAxisAlignment.start,
//                      children: <Widget>[
//                        Padding(
//                          padding: const EdgeInsets.only(right: 8.0),
//                          child: new Text(userSing.userFName, style: descriptionStyle),
//                        ),
//                        new Text(userSing.userLName, style: descriptionStyle,)
//                      ],
//                    ),
//                  ),
//                  Container(
//                    padding: EdgeInsets.only(bottom: 4.0),
//                    child: new Text("Email", style: titleStyle,),
//                  ),
//                  new Text(userSing.userEmail, style: descriptionStyle,)
//              ]
//              )
//            ),
//          ],
//        )
    );
  }

}