
import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//import 'package:image_picker/image_picker.dart';

class AddNewsItemPage extends StatefulWidget{
  @override
  _AddNewsItemPageState createState() => new _AddNewsItemPageState();
}

class _AddNewsItemPageState extends State<AddNewsItemPage>{
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  File _image;
  DateTime selectedDate;
  Future getImage() async {
    //var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      //_image = image;
    });
  }
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle titleStyle = theme.textTheme.headline.copyWith(color: Colors.black);
    final TextStyle subStyle = theme.textTheme.body1;
    final format = new DateFormat('dd-MM-yyyy');

    String description;
    String title;
    String imgurl;
    return new Scaffold(
      appBar: new AppBar(
        title: Text("Add Announcement"),
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
//                  new Text("Upload Image", style: titleStyle,),
//                  new IconButton(icon: Icon(Icons.add_a_photo), onPressed: getImage,),
//                  new Center(
//                    child: _image == null
//                        ? new Text('No image selected.')
//                        : new Image.file(_image),
//                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: new TextFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                        labelStyle: titleStyle.copyWith(color: Colors.black54),
                        isDense: false,
                        labelText: "Image URL",
                        hintText: "Enter Image URL Here",
                      ),

                      validator: (value){
                        if (value.isEmpty) {
                          return 'Please enter some text';
                        }
                      },
                      onSaved: (value){
                        imgurl = value;
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
                          labelText: "Announcement Title",
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
                  new Text("Select Date", style: titleStyle,),
                  new Row(
                    children: <Widget>[
                      new IconButton(
                          alignment: Alignment.centerLeft,
                          icon: Icon(Icons.today),
                          onPressed: ()async {
                            DateTime newDT = await showDatePicker(
                              context: context,
                              initialDate: selectedDate ?? new DateTime.now(),
                              firstDate: new DateTime(1960),
                              lastDate: new DateTime(2050),
                            );
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
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: new TextFormField(
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          ),
                          labelStyle: titleStyle,
                          labelText: "Announcement Description",
                          hintText: "Enter Description Here"
                      ),
                      onSaved: (value){
                        description = value;
                      },
                    ),
                  ),
                  new RaisedButton(
                      child: new Text("Submit"),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                      onPressed: (){
                        final FormState form = _formKey.currentState;
                        form.save();
                        Map<String, dynamic> dataMap = new Map<String, dynamic>();
                        dataMap["date"] = selectedDate;
                        dataMap["description"] = description;
                        dataMap["newsImgUrl"] = imgurl;
                        dataMap["title"] = title;
                        Firestore.instance.collection('announcements').document().setData(dataMap);
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