import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

class AddEventPage extends StatefulWidget{
  @override
  _AddEventPageState createState() => new _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage>{
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  DateTime selectedDate;
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle titleStyle = theme.textTheme.headline.copyWith(color: Colors.black);
    final TextStyle subStyle = theme.textTheme.body1.copyWith(fontSize: 22.0);
    final format = new DateFormat('dd-MM-yyyy');

    String committeeName;
    String title;

    return new Scaffold(
      appBar: new AppBar(
        title: Text("Add Event"),
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
                    child: new TextFormField(
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          ),
                          labelStyle: titleStyle,
                          labelText: "Event Title",
                          hintText: "Enter Title Here"
                      ),
                      validator: (value){
                        if (value.isEmpty) {
                          return 'Please enter some text';
                        }
                      },
                      onSaved: (value){
                        title = value;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: new TextFormField(
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          ),
                          labelStyle: titleStyle,
                          labelText: "Committee Name",
                          hintText: "Enter Committee Name Here"
                      ),
                      onSaved: (value){
                        committeeName = value;
                      },
                    ),
                  ),
                  new Container(
                    margin: EdgeInsets.only(bottom: 16.0),
                    decoration: new BoxDecoration(
                      border: new Border.all(color: Colors.black54),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                          child: new Text("Select Date", style: titleStyle, ),
                        ),
                        new Row(
                          children: <Widget>[
                            new IconButton(
                                iconSize: 48.0,
                                alignment: Alignment.centerLeft,
                                icon: Icon(Icons.today),
                                onPressed: ()async {
                                  DateTime newDT;
                                  DateTime today = DateTime.now();
                                  final ios = Theme.of(context).platform == TargetPlatform.iOS;
                                  if (!ios) {
                                    newDT = await showDatePicker(
                                      context: context,
                                      initialDate: selectedDate ?? new DateTime.now(),
                                      firstDate: new DateTime(1960),
                                      lastDate: new DateTime(2050),
                                    );
                                  }else if(ios){
                                    DatePicker.showDatePicker(
                                      context,
                                      minYear: 1970,
                                      maxYear: 2070,
                                      initialYear: today.year,
                                      initialMonth: today.month,
                                      initialDate: today.day,
                                      onChanged: (year, month, date) {
                                        print('onChanged date: $year-$month-$date');
                                      },
                                      onConfirm: (year, month, date) {
                                        setState(() {
                                          selectedDate = new DateTime.utc(year,month,date);
                                        });
                                      },
                                    );
                                  }
                                  setState(() {
                                    selectedDate = newDT;
                                  });
                                }),
                            new Text(
                              selectedDate == null ? "No Date Selected" : format.format(selectedDate),
                              style: selectedDate == null ? subStyle.copyWith(color: Colors.black54) : subStyle,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  new RaisedButton(
                      child: new Text("Submit"),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                      onPressed: ()async {
                        final FormState form = _formKey.currentState;
                        form.save();
                        Map<String, dynamic> dataMap = new Map<String, dynamic>();
                        Map<String, dynamic> dataDocMap = new Map<String, dynamic>();
                        dataMap["name"] = committeeName;
                        dataMap["title"] = title;
                        DocumentSnapshot ds = await Firestore.instance.collection('events').
                        document(selectedDate.month.toString() + '-' + selectedDate.year.toString()).get();
                        List<String> newDays;
                        if(ds.data != null){
                          var days = new List<String>.from(ds['days']);
                          if(days.contains(selectedDate.day.toString())){
                            dataDocMap["days"] = days;
                          }else{
                            days.add(selectedDate.day.toString());
                            dataDocMap["days"] = days;
                          }
                        }else{
                          List<String> newDays = new List();
                          newDays.add(selectedDate.day.toString());
                          dataDocMap["days"] = newDays;
                        }

                        Firestore.instance.collection('events')
                            .document(selectedDate.month.toString() + '-' + selectedDate.year.toString())
                            .setData(dataDocMap);
                        Firestore.instance.collection('events')
                            .document(selectedDate.month.toString() + '-' + selectedDate.year.toString())
                            .collection(selectedDate.day.toString())
                            .document()
                            .setData(dataMap);
                        Navigator.pop(context);

                      }
                  )
                ],
              ),
            ),
          )
      ),
    );
  }

}