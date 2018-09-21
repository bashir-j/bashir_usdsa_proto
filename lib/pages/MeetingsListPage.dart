

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:usdsa_proto/UserSingleton.dart';
import 'package:usdsa_proto/pages/AddMeetingPage.dart';
import 'package:usdsa_proto/pages/MeetingPage.dart';

class meetingsList extends StatefulWidget{
  meetingsList({@required this.committeeName, this.jUsers});
  final String committeeName;
  final List<String> jUsers;

  @override
  _meetingsListState createState() => new _meetingsListState();

}

class _meetingsListState extends State<meetingsList>{
  UserSingleton userSing = new UserSingleton();
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text("Committee Meetings"),
        actions: userSing.userPriority == '2' ? <Widget>[
          new IconButton(icon: Icon(Icons.add), onPressed: (){
            Navigator.push(
              context,
              new MaterialPageRoute(builder: (context) => new AddMeetingPage(committeeName: widget.committeeName,)),
            );
          }),
        ] : null,
      ),
      body: new SafeArea(
        top: false,
        bottom: false,
        child: new StreamBuilder(
            stream: Firestore.instance.collection('committees').document(widget.committeeName).collection('meetings').orderBy("date", descending: true).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Center(child: new CircularProgressIndicator());
              return new Scrollbar(
                  child: new ListView.builder(
                      itemCount: snapshot.data.documents.length,
                      itemExtent: 75.0,
                      padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                      itemBuilder: (context, index){
                        DocumentSnapshot ds = snapshot.data.documents[index];
                        DateTime dt = ds['date'];
                        final format = new DateFormat('dd-MM-yyyy');
                        final tformat = new DateFormat.jm();
                        List<String> aUsers = new List<String>.from(ds['aUsers']);
                        bool attended = aUsers.contains(userSing.userID);
                        MeetingItem snapshotToItem = new MeetingItem(
                          title: ds['name'],
                          date: format.format(dt),
                          aUsers: aUsers,
                          description: ds['description'],
                          attended: attended,
                          meetingID: ds.documentID,
                          committeeName: widget.committeeName,
                          time: tformat.format(dt),
                          jUsersCommittee: widget.jUsers,
                        );
                        return ListTile(
                          onTap: (){
                            Navigator.of(context).push(
                              new MaterialPageRoute(builder: (context) => new MeetingPage(meetingItem: snapshotToItem)),
                            );
                          },
                          title: Text(snapshotToItem.title),
                          subtitle: Text(snapshotToItem.date),
                          leading: attended ? Icon(Icons.check): Icon(Icons.clear),
                          trailing: Icon(Icons.chevron_right),
                        );
                      }
                  )
              );
            }
        ),
      ),
    );
  }



}