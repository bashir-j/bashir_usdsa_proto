

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class groupInfo extends StatefulWidget{
  groupInfo({@required this.committeeName, this.jUsers, this.headEmail, this.headName});
  final String committeeName;
  final List<String> jUsers;
  final String headName;
  final String headEmail;

  @override
  _groupInfoState createState() => new _groupInfoState();

}

class _groupInfoState extends State<groupInfo>{

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle titleStyle = theme.textTheme.headline.copyWith(color: Colors.black, fontSize: 32.0);
    final TextStyle descriptionStyle = theme.textTheme.subhead.copyWith(fontSize: 24.0);
    return new Scaffold(
        appBar: new AppBar(
          title: Text("Group Info"),
        ),
        body: Column(
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
                        title: new Text(widget.headName, style: TextStyle(fontSize: 20.0),),
                        subtitle: new Text(widget.headEmail),
                      ),
                    ],
                  ),
                ),
                Container(
                    margin: EdgeInsets.only(left: 32.0, top: 20.0),
                    decoration: BoxDecoration(color: theme.scaffoldBackgroundColor),
                    //padding: EdgeInsets.only(left: 64.0, top: 4.0),
                    child: new Text("Committee Head", style: titleStyle,)
                ),
              ],
            ),
            Expanded(
              child: Stack(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 48.0, bottom: 16.0),
                    //padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0),
                    decoration: BoxDecoration(
                      border: new Border.all(color: Colors.black54, width: 2.0),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    child:
                    Scrollbar(
                      child: new StreamBuilder(
                          stream: Firestore.instance.collection('users').snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return Center(child: new CircularProgressIndicator());
                            List<DocumentSnapshot> filtered = snapshot.data.documents;
                            filtered.removeWhere((ds){
                              return !widget.jUsers.contains(ds.documentID);
                            });
                            print(filtered.length);
                            return ListView.builder(
                                shrinkWrap: true,
                                itemCount: filtered.length,
                                itemExtent: 40.0,
                                padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: new Text(filtered.elementAt(index)['fname'] + ' ' + filtered.elementAt(index)['lname']),
                                  );
                                }
                            );
                          }
                      ),
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.only(left: 32.0, top: 20.0),
                      decoration: BoxDecoration(color: theme.scaffoldBackgroundColor),
                      //padding: EdgeInsets.only(left: 64.0, top: 4.0),
                      child: new Text("Committee Members", style: titleStyle,)
                  ),
                ],
              ),
            ),
          ],
        ),
    );

  }

}