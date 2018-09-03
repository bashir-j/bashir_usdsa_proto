import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:usdsa_proto/flutter_calendar_mod/flutter_calendar.dart';


class eventItem{
  const eventItem({
    this.title,
    this.committeeName,
  });

  final String title;
  final String committeeName;

  //bool get isValid => groupIconURL != null && groupName != null && description != null;
}
class activityCalendarBuilder extends StatefulWidget {
  @override
  _activityCalendarState createState() => new _activityCalendarState();
}

class _activityCalendarState extends State<activityCalendarBuilder> {
  DateTime selectedDate = new DateTime.now();
  List<eventItem> dayevents = new List<eventItem>();
  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Calendar(
          isExpandable: false,
          onDateSelected: (newSelectedDate) async {
            List<eventItem> tempdayevents = new List<eventItem>();
            dayevents.clear();
            String newMonth = newSelectedDate.month.toString();
            String newYear = newSelectedDate.year.toString();
            String newDay = newSelectedDate.day.toString();
            Firestore.instance.collection('events').document(newMonth + '-' + newYear).collection(newDay).getDocuments()
                .then((value){
              value.documents.forEach((eventSnapshot){
                eventItem tempEvent = new eventItem(
                  title: eventSnapshot['title'],
                  committeeName: eventSnapshot['name'],
                );
                tempdayevents.add(tempEvent);
                setState(() {
                  dayevents = tempdayevents;
                });
                print(tempEvent);
              });
            });
            setState(() {
              selectedDate = newSelectedDate;
            });
          },
        ),
        new Expanded(child: _eventHolderBuilder())

      ],
    );
  }




Widget _eventHolderBuilder(){
    if(dayevents.isEmpty) {
      return new ListView(
        children: <Widget>[
          new Text("No events on the day of"),
          new Text(selectedDate.day.toString() + '/' +
              selectedDate.month.toString()),
        ],
      );
    }
    else{
      return new ListView(
        children: <Widget>[
          new Text(dayevents.elementAt(0).committeeName),
          new Text(dayevents.elementAt(0).title),
        ],
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


