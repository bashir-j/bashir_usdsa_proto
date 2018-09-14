

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:usdsa_proto/UserSingleton.dart';
//import 'package:qrcode_reader/QRCodeReader.dart';

class MeetingItem{
  const MeetingItem({
    this.title,
    this.date,
    this.description,
    this.aUsers,
    this.attended,
    this.meetingID,
    this.committeeName,
    this.time,
    this.jUsersCommittee,
  });

  final String title;
  final List<String> aUsers;
  final String date;
  final String description;
  final bool attended;
  final String meetingID;
  final String committeeName;
  final String time;
  final List<String> jUsersCommittee;
}


class MeetingPage extends StatefulWidget{
  MeetingPage({@required this.meetingItem});
  final MeetingItem meetingItem;

  @override
  _meetingPageState createState() => new _meetingPageState();

}

class _meetingPageState extends State<MeetingPage> {
  UserSingleton userSing = new UserSingleton();
  bool dAttended;
  //String mID = "default";
  @override
  void initState() {
    super.initState();
    dAttended = widget.meetingItem.attended;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle titleStyle = theme.textTheme.headline.copyWith(color: Colors.black);
    final TextStyle subStyle = theme.textTheme.body1.copyWith(fontSize: 22.0);
    return new Scaffold(
        appBar: new AppBar(
        title: Text(widget.meetingItem.title),
        ),
        body: new SafeArea(
          top: false,
          bottom: false,
          child: Column(
            children :<Widget>[
              Container(
              padding: EdgeInsets.all(16.0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: new Text("Description", style: titleStyle,),
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: 16.0),
                    child: new Text(widget.meetingItem.description),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0),
                    decoration: BoxDecoration(
                      border: new Border.all(color: Colors.black54, width: 2.0),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(bottom: 4.0),
                          child: Row(children: <Widget>[
                            new Text("Date & Time", style: titleStyle,),
                          ],
                          ),
                        ),
                        Container(
                          child: new Text(widget.meetingItem.date + ' ' + widget.meetingItem.time),
                          padding: EdgeInsets.only(bottom: 8.0),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 16.0),
                    decoration: BoxDecoration(
                      border: new Border.all(color: Colors.black54, width: 2.0),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    padding: EdgeInsets.only(top: 16.0, bottom: 16.0, left: 8.0, right: 8.0),
                    child: dAttended ?
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Text("Meeting Attended", style: titleStyle,),
                        new Icon(Icons.check)
                      ],
                    ):
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Text("Attend Meeting", style: titleStyle,),
                        new IconButton(
                            icon: Icon(Icons.camera_enhance),
                            onPressed: (){
                              attendMeeting();
                            },
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            new StreamBuilder(
                stream: Firestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Center(child: new CircularProgressIndicator());
                  return Expanded(
                    child: new Scrollbar(
                        child: ListView.builder(
                            itemCount: widget.meetingItem.jUsersCommittee.length,
                            itemExtent: 110.0,
                            padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                            itemBuilder: (context, index) {
                              DocumentSnapshot ds = snapshot.data.documents[index];
                              if(widget.meetingItem.jUsersCommittee.contains(ds.documentID)){
                                bool uAttended = widget.meetingItem.aUsers.contains(ds.documentID);
                                return ListTile(
                                  leading: uAttended ? Icon(Icons.check_box, color: theme.primaryColor,) : Icon(Icons.check_box_outline_blank, color: theme.primaryColor,),
                                  title: new Text(ds.documentID),
                                );
                              }
                            }
                        )
                    ),
                  );
                }
            ),
            ]
          ),
        ),
    );
  }


  attendMeeting()async {
      //String futureString = await new QRCodeReader().scan();
    Map<String, dynamic> dataMap = new Map<String, dynamic>();
    widget.meetingItem.aUsers.add(userSing.userID);
    dataMap['aUsers'] = widget.meetingItem.aUsers;

    await Firestore.instance
        .collection('committees')
        .document(widget.meetingItem.committeeName)
        .collection('meetings')
        .document(widget.meetingItem.meetingID)
        .setData(dataMap, merge: true);
    setState(() {
      dAttended = true;
      //mID = futureString;
    });
  }
}