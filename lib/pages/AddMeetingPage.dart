
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:intl/intl.dart';

class AddMeetingPage extends StatefulWidget{
  AddMeetingPage({@required this.committeeName});
  final String committeeName;

  @override
  _AddMeetingPageState createState() => new _AddMeetingPageState();
}

class _AddMeetingPageState extends State<AddMeetingPage>{

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  DateTime selectedDate = DateTime.now();
  int _selectedHourIndex = 0;
  List<int> hours = List<int>.generate(TimeOfDay.hoursPerDay, (index){
    return index;
  });
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle titleStyle = theme.textTheme.headline.copyWith(color: Colors.black);
    final TextStyle subStyle = theme.textTheme.body1.copyWith(fontSize: 22.0);
    final format = new DateFormat('dd-MM-yyyy');
    final timeFormat = new DateFormat.jm();
    String description;
    String title;

    return new Scaffold(
      appBar: new AppBar(
        title: Text("Add Meeting"),
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
                          labelText: "Meeting Title",
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
                          labelText: "Meeting Description",
                          hintText: "Enter Description Here"
                      ),
                      validator: (value){
                        if (value.isEmpty) {
                          return 'Please enter some text';
                        }
                      },
                      onSaved: (value){
                        description = value;
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
                                          selectedDate = new DateTime.utc(year,month,date,selectedDate.hour,selectedDate.minute);
                                        });
                                      },
                                    );
                                  }
                                  setState(() {
                                    selectedDate = new DateTime.utc(newDT.year,newDT.month,newDT.day,selectedDate.hour,selectedDate.minute);
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
                          child: new Text("Select Time", style: titleStyle, ),
                        ),
                        new Row(
                          children: <Widget>[
                            new IconButton(
                                iconSize: 48.0,
                                alignment: Alignment.centerLeft,
                                icon: Icon(Icons.access_time),
                                onPressed: ()async {
                                  TimeOfDay newTOD;
                                  DateTime today = new DateTime.now();
                                  final ios = Theme.of(context).platform == TargetPlatform.iOS;
                                  if (!ios) {
                                    newTOD = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now()
                                    );
                                    setState(() {
                                      selectedDate = new DateTime.utc(selectedDate.year,selectedDate.month,selectedDate.day,newTOD.hour,newTOD.minute);
                                    });
                                  }else if(ios){
                                    //TODO Finish IOS TimePicker
                                    await showCupertinoModalPopup(context: context,
                                        builder: (BuildContext context){
                                          return _buildBottomPicker(_buildHourPicker());
                                        }
                                    );
                                    setState(() {
                                      selectedDate = new DateTime.utc(selectedDate.year,selectedDate.month,selectedDate.day,hours[_selectedHourIndex],15);
                                    });
//                                    DatePicker.showDatePicker(
//                                      context,
//                                      minYear: 1970,
//                                      maxYear: 2070,
//                                      initialYear: today.year,
//                                      initialMonth: today.month,
//                                      initialDate: today.day,
//                                      onChanged: (year, month, date) {
//                                        print('onChanged date: $year-$month-$date');
//                                      },
//                                      onConfirm: (year, month, date) {
//                                        setState(() {
//                                          selectedDate = new DateTime.utc(selectedDate.year,selectedDate.month,selectedDate.day,newTOD.hour,newTOD.minute);
//                                        });
//                                      },
//                                    );
                                  }
                                }),
                            new Text(
                              selectedDate == null ? "No Time Selected" : timeFormat.format(selectedDate),
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
                        if (form.validate() && selectedDate != null) {
                          showDialog(context: context,
                              barrierDismissible: false,
                              builder: (context) {
                                return Center(
                                  child: Container(
                                      child: new CircularProgressIndicator()
                                  ),
                                );
                              }
                          );
                          form.save();
                          Map<String, dynamic> dataMap = new Map<String,
                              dynamic>();
                          List<String> aUsers = new List<String>();
                          Map<String, dynamic> dataDocMap = new Map<
                              String,
                              dynamic>();
                          dataMap["date"] = selectedDate;
                          dataMap["name"] = title;
                          dataMap["description"] = description;
                          dataMap["aUsers"] = aUsers;

                          await Firestore.instance.collection('committees')
                              .document(widget.committeeName)
                              .collection('meetings')
                              .document()
                              .setData(dataMap);

                          Navigator.pop(context);
                          Navigator.pop(context);
                        }
                      }
                  )
                ],
              ),
            ),
          )
      ),
    );
  }
  Widget _buildBottomPicker(Widget picker) {
    const double _kPickerSheetHeight = 216.0;
    return Container(
      height: _kPickerSheetHeight,
      color: CupertinoColors.white,
      child: DefaultTextStyle(
        style: const TextStyle(
          color: CupertinoColors.black,
          fontSize: 22.0,
        ),
        child: GestureDetector(
          // Blocks taps from propagating to the modal sheet and popping.
          onTap: () {},
          child: SafeArea(
            child: picker,
          ),
        ),
      ),
    );
  }
  Widget _buildHourPicker() {
    const double _kPickerItemHeight = 32.0;
    final FixedExtentScrollController scrollController =
    FixedExtentScrollController(initialItem: _selectedHourIndex);
    return CupertinoPicker(
        looping: true,
        scrollController: scrollController,
        itemExtent: _kPickerItemHeight,
        backgroundColor: CupertinoColors.white,
        onSelectedItemChanged: (int index) {
          setState(() {
            _selectedHourIndex = index;
          });
        },
        children: List<Widget>.generate(hours.length, (int index) {
      return Center(child:
      Text(hours[index].toString()),
      );
    }),
    );
  }
}