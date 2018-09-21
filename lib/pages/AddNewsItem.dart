
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;
import 'package:image_cropper/image_cropper.dart';
import 'package:usdsa_proto/EnsureVisWhileFocused.dart';
import 'package:http/http.dart';

class AddNewsItemPage extends StatefulWidget{



  @override
  _AddNewsItemPageState createState() => new _AddNewsItemPageState();
}

class _AddNewsItemPageState extends State<AddNewsItemPage>{
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  File _image;
  DateTime selectedDate;

  FocusNode _focusNodeTitleName = new FocusNode();
  FocusNode _focusNodeDescriptionName = new FocusNode();

  Future _uploadImage(Map<String, dynamic> dataMap) async {
    final ios = Theme.of(context).platform == TargetPlatform.iOS;
    // fetch file name
    String fileName = p.basename(_image.path);
    if(!ios){
      fileName = DateTime.now().toString();
    }
    final StorageReference ref = FirebaseStorage.instance.ref().child(
        "images/$fileName");
    final StorageUploadTask uploadTask = ref.putFile(_image, StorageMetadata(contentLanguage: "en"));

    final Uri downloadUrl = (await uploadTask.future).downloadUrl;

    dataMap["newsImgUrl"] = downloadUrl.toString();
    dataMap["imgRef"] = "images/$fileName";

    String notifBody = dataMap["description"];
//    if(notifBody.length > 60) {
//      notifBody = notifBody.substring(0, 60);
//      notifBody = notifBody + '...';
//    }
    Map<String, String> headers = {
      'Content-type' : 'application/json',
      'Authorization': 'key=AIzaSyC7GOT3cQ9CcyWctrvjUXgaYRBV1zXeg3E',
    };
    Map<String, String> notif = {
      'sound': 'default',
      'body' : notifBody,
      'title': 'New Announcement Added',
    };
    Map<String, String> data = {
      'click_action' : 'FLUTTER_NOTIFICATION_CLICK',
      "id": "12",
      "status": "done"
    };
    Map body = {
      'notification' : notif,
      'priority': 'high',
      'data': data,
      "to": "/topics/announcements"
    };
    var vBody = jsonEncode(body);
    Response resp = await post(
      Uri.encodeFull("https://fcm.googleapis.com/fcm/send"),
      headers: headers,
      body: vBody,
    );
    print(resp.body);

    setState(() {
      Firestore.instance.collection('announcements').document().setData(dataMap);
      Navigator.pop(context);
      Navigator.pop(context);
    });
  }

  Future getImage() async {
    var imagePreCrop = await ImagePicker.pickImage(source: ImageSource.gallery);
    var image = await ImageCropper.cropImage(
      sourcePath: imagePreCrop.path,
      ratioX: 1.666,
      ratioY: 1.0,
      maxWidth: 512,
      maxHeight: 512,
    );
    setState(() {
      _image = image;
    });
  }
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle titleStyle = theme.textTheme.headline.copyWith(color: Colors.black);
    final TextStyle subStyle = theme.textTheme.body1.copyWith(fontSize: 22.0);
    final format = new DateFormat('dd-MM-yyyy');

    String description;
    String title;
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: new Scaffold(
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
                            child: new Text("Upload Image", style: titleStyle, ),
                          ),
                          new Row(
                            children: <Widget>[
                              new IconButton(
                                  iconSize: 48.0,
                                  alignment: Alignment.centerLeft,
                                  icon: Icon(Icons.add_a_photo),
                                  onPressed: getImage
                              ),
                              new Expanded(
                                child: _image == null ?
                                Text("No Image Selected",
                                  style: subStyle.copyWith(color: Colors.black54)) :
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.file(_image),
                                )
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: new EnsureVisibleWhenFocused(
                        focusNode: _focusNodeTitleName,
                        child: new TextFormField(
                          focusNode: _focusNodeTitleName,
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
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: new EnsureVisibleWhenFocused(
                        focusNode: _focusNodeDescriptionName,
                        child: new TextFormField(
                          keyboardType: TextInputType.multiline,
                          focusNode: _focusNodeDescriptionName,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              ),
                              labelStyle: titleStyle,
                              labelText: "Announcement Description",
                              hintText: "Enter Description Here"
                          ),
                          maxLines: 3,
                          maxLengthEnforced: true,
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
                    ),
                    new RaisedButton(
                        child: new Text("Submit"),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                        onPressed: (){
                          final FormState form = _formKey.currentState;
                          if(form.validate() && _image != null && selectedDate != null) {
                            showDialog(context: context,
                                barrierDismissible: false,
                                builder: (context){
                              return Center(
                                child: Container(child: new CircularProgressIndicator()
                                ),
                              );
                            }
                            );
                            form.save();
                            Map<String, dynamic> dataMap = new Map<
                                String,
                                dynamic>();
                            dataMap["date"] = selectedDate;
                            dataMap["description"] = description;
                            dataMap["title"] = title;
                            _uploadImage(dataMap);
                          }
                        }
                    )
                  ],
                ),
              ),
            )
        ),
      ),
    );
  }

}