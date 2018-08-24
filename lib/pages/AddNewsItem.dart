
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
//import 'package:image_picker/image_picker.dart';

class AddNewsItemPage extends StatefulWidget{
  @override
  _AddNewsItemPageState createState() => new _AddNewsItemPageState();
}

class _AddNewsItemPageState extends State<AddNewsItemPage>{

  File _image;

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
    return new Scaffold(
      appBar: new AppBar(
        title: Text("Add Announcement"),
      ),
      body: new SafeArea(
          top: false,
          bottom: false,
          child: new Container(
            padding: const EdgeInsets.all(16.0),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text("Upload Image", style: titleStyle,),
                new IconButton(icon: Icon(Icons.add_a_photo), onPressed: getImage,),
                new Center(
                  child: _image == null
                      ? new Text('No image selected.')
                      : new Image.file(_image),
                ),
              ],
            ),
          )
      ),
    );
  }

}