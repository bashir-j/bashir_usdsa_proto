import 'package:flutter/material.dart';
import 'package:usdsa_proto/flutter_calendar_mod/flutter_calendar.dart';

class activityCalendarBuilder extends StatefulWidget {
  @override
  _activityCalendarState createState() => new _activityCalendarState();
}

class _activityCalendarState extends State<activityCalendarBuilder> {
  DateTime selectedDate = new DateTime.now();
  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Calendar(
          isExpandable: false,
          onDateSelected: (newSelectedDate) {
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
    return new ListView(
      children: <Widget>[
        new Text("No events on the day of"),
        new Text(selectedDate.day.toString() + '/' + selectedDate.month.toString()),
      ],
    );
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


