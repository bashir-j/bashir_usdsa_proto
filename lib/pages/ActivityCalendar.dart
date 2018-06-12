import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

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
          isExpandable: true,
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
        new Text(selectedDate.day.toString()),
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


