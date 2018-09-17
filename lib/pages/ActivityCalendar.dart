import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:usdsa_proto/UserSingleton.dart';
import 'package:usdsa_proto/flutter_calendar_mod/flutter_calendar.dart';


class eventItem{
  const eventItem({
    this.title,
    this.committeeName,
    this.eventRef,
    this.collectionRef,
    this.date,
  });

  final String title;
  final String committeeName;
  final DocumentReference eventRef;
  final CollectionReference collectionRef;
  final DateTime date;

  //bool get isValid => groupIconURL != null && groupName != null && description != null;
}
class activityCalendarBuilder extends StatefulWidget {
  activityCalendarBuilder({@required this.now});
  DateTime now;
  @override
  _activityCalendarState createState() => new _activityCalendarState();
}

class _activityCalendarState extends State<activityCalendarBuilder> {
  DateTime selectedDate = new DateTime.now();
  List<eventItem> dayevents = new List<eventItem>();
  UserSingleton userSing = new UserSingleton();
  bool fetchingDayevents = false;
  @override
  Widget build(BuildContext context) {
    //widget.reloader = true;
    return new Column(
      children: <Widget>[
        Expanded(
          flex:0,
          child: new Calendar(
            isExpandable: false,
            onDateSelected: (newSelectedDate) async {
              List<eventItem> tempdayevents = new List<eventItem>();
              dayevents.clear();
              fetchingDayevents = true;
              String newMonth = newSelectedDate.month.toString();
              String newYear = newSelectedDate.year.toString();
              String newDay = newSelectedDate.day.toString();
              Firestore.instance.collection('events').document(
                  newMonth + '-' + newYear).collection(newDay).getDocuments()
                  .then((value) {
                value.documents.forEach((eventSnapshot) {
                  eventItem tempEvent = new eventItem(
                    collectionRef: Firestore.instance.collection('events')
                        .document(newMonth + '-' + newYear).collection(newDay)
                        .reference(),
                    eventRef: eventSnapshot.reference,
                    title: eventSnapshot['title'],
                    committeeName: eventSnapshot['name'],
                    date: newSelectedDate,
                  );
                  tempdayevents.add(tempEvent);
                  print(tempEvent);
                });
                setState(() {
                  dayevents = tempdayevents;
                  fetchingDayevents = false;
                });
              });
              setState(() {
                selectedDate = newSelectedDate;
              });
            },
          ),
        ),
        new Flexible(
            child: _eventHolderBuilder())
      ],
    );


  }

  deleteEvent(eventItem eventTBD){
    final ios = Theme.of(context).platform == TargetPlatform.iOS;
    showDialog(context: context, builder: (BuildContext context){
      if(!ios){
        return new AlertDialog(
          title: new Text("Delete Event"),
          content: new Text("Are you sure you would like to delete this event?"),
          actions: <Widget>[
            new FlatButton(onPressed: (){
              Navigator.of(context).pop();
            },
            child: new Text("Cancel")
            ),
            new FlatButton(onPressed: ()async {
              await eventTBD.eventRef.delete();
              await eventTBD.collectionRef.getDocuments().then((value)async {
                print(value.toString());
                print(value.documents.isEmpty);
                if(value.documents.isEmpty){
                  print("isempty");
                  Map<String, dynamic> dataDocMap = new Map<String, dynamic>();
                  DocumentSnapshot ds = await Firestore.instance.collection('events').
                  document(selectedDate.month.toString() + '-' + selectedDate.year.toString()).get();
                  var days = new List<String>.from(ds['days']);
                  print(days);
                  days.remove(selectedDate.day.toString());
                  print(days);
                  dataDocMap["days"] = days;
                  await Firestore.instance.collection('events')
                      .document(selectedDate.month.toString() + '-' + selectedDate.year.toString())
                      .setData(dataDocMap);
                }
              });
              setState(() {

              });
              Navigator.of(context).pop();
            },
            child: new Text("Delete"),
            textColor: Colors.red,
            ),
          ],
        );
      }else{
        return new CupertinoAlertDialog(
          title: new Text("Delete Event"),
          content: new Text("Are you sure you would like to delete this event?"),
          actions: <Widget>[
            new CupertinoDialogAction(
              child: new Text("Cancel"),
              onPressed: (){
                Navigator.of(context).pop();
              },
            ),
            new CupertinoDialogAction(
              child: new Text("Delete"),
              isDestructiveAction: true,
              onPressed: ()async {
                await eventTBD.eventRef.delete();
                await eventTBD.collectionRef.getDocuments().then((value)async {
                  print(value.toString());
                  print(value.documents.isEmpty);
                  if(value.documents.isEmpty){
                    print("isempty");
                    Map<String, dynamic> dataDocMap = new Map<String, dynamic>();
                    DocumentSnapshot ds = await Firestore.instance.collection('events').
                    document(selectedDate.month.toString() + '-' + selectedDate.year.toString()).get();
                    var days = new List<String>.from(ds['days']);
                    print(days);
                    days.remove(selectedDate.day.toString());
                    print(days);
                    dataDocMap["days"] = days;
                    await Firestore.instance.collection('events')
                        .document(selectedDate.month.toString() + '-' + selectedDate.year.toString())
                        .setData(dataDocMap);
                  }
                });
                setState(() {

                });
                Navigator.of(context).pop();
              },
            )
          ],
        );
      }
    }).whenComplete((){

    });
  }


List<Widget> eventCardBuilder(){
  final ThemeData theme = Theme.of(context);
  final TextStyle descriptionStyle = theme.textTheme.subhead;

    List<Widget> eventCards = new List();
    dayevents.forEach((event){
      eventCards.add(
        Container(
          decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 2.0,color: Colors.black12))),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Container(
                width: 10.0,
                height: 60.0,
                decoration: BoxDecoration(color: Colors.orange, shape: BoxShape.rectangle),
              ),
              new Expanded(
                child: new Container(
                  padding: EdgeInsets.only(left: 4.0),
                  height: 60.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text(event.title,style: descriptionStyle.copyWith(color: Colors.black),),
                      new Text(event.committeeName,style: descriptionStyle.copyWith(color: Colors.black54),)
                    ],
                  )
                ),
              ),
              new Container(
                child: userSing.userPriority == '2' ? new IconButton(icon: Icon(Icons.delete), onPressed: () => deleteEvent(event)) : null,
              ),
            ],
          ),
        )
      );
    });
    return eventCards;
}

Widget _eventHolderBuilder(){
  final ThemeData theme = Theme.of(context);
  final TextStyle descriptionStyle = theme.textTheme.subhead;
    if(dayevents.isEmpty && !fetchingDayevents) {
      return new Center(
        child: new Text("No Events",style: descriptionStyle.copyWith(color: Colors.black, fontSize: 24.0),),
      );
    }
    else if(dayevents.isEmpty && fetchingDayevents){
      return new Center(
        child: new CircularProgressIndicator(),
      );
    }
    else{
      return new ListView(
        children: eventCardBuilder(),
      );
    }
}
}

class Event{
  const Event({
    this.title,
    this.subtitle,
    this.date,
});

  final String title;
  final String subtitle;
  final DateTime date;


}


