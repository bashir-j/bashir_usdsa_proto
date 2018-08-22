import 'package:flutter/material.dart';
import '../theme.dart';
import 'NewsStream.dart';
import 'ActivityCalendar.dart';
import 'GroupsList.dart';
import 'AddNewsItem.dart';
import '../group_options_icons_icons.dart';


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: "USDSA App",
        home: new usdsaApp(),
        theme: mainTheme,
    );
  }
}

class usdsaApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new usdsaAppState();
}

class usdsaAppState extends State<usdsaApp>{

  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "USDSA App",
      home: scaffoldCreator(),
      theme: mainTheme,
    );
  }


  Scaffold scaffoldCreator(){

    return new Scaffold(
      appBar: new AppBar(
        title: titleChoser(),
        actions: actionsBuilder(),
      ),
      body: screenChoser(),
      bottomNavigationBar: new BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          new BottomNavigationBarItem(icon: new Icon(GroupOptionsIcons.newspaper), title: new Text("News")),
          new BottomNavigationBarItem(icon: new Icon(Icons.calendar_today), title: new Text("Calendar")),
          new BottomNavigationBarItem(icon: new Icon(GroupOptionsIcons.group), title: new Text("Groups")),
          new BottomNavigationBarItem(icon: new Icon(Icons.settings), title: new Text("Settings")),
        ],
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (int index){
          setState(() {
            _currentIndex = index;
          });
        },

      ),

    );
  }

  List<Widget> actionsBuilder(){
    switch(_currentIndex){
      case 0:{
        if (true) {
          return <Widget>[
            new IconButton(icon: Icon(Icons.add), onPressed: (){
              Navigator.push(
                context,
                new MaterialPageRoute(builder: (context) => new AddNewsItemPage()),
              );
            }),
          ];
        }
        else{
          return <Widget>[];
        }
      }
      break;
      case 2:{
        return <Widget>[
          new IconButton(icon: Icon(Icons.add), onPressed: null),
          new IconButton(icon: Icon(Icons.camera_enhance), onPressed: null)
        ];
      }
      break;
      default: {
        return [];
      }
      break;
    }
  }

  Text titleChoser(){
    switch(_currentIndex){
      case 0:{
        return Text('Announcements');
      }
      break;
      case 1: {
        return Text('Events Calendar');
      }
      break;
      case 2: {
        return new Text("My Groups");
      }
      break;

      default: {
        return new Text("default error");
      }
      break;
    }
  }

  Widget screenChoser(){

    switch(_currentIndex){
      case 0:{
        return new newsStreamBuilder();
      }
      break;
      case 1: {
        return new activityCalendarBuilder();
      }
      break;
      case 2: {
        return new groupsListBuilder();
      }
      break;

      default: {
        return new Text("default error");
      }
      break;
    }
  }
}





