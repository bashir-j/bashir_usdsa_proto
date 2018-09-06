import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'GroupOptionsPage.dart';

class GroupItem{
  const GroupItem({
    this.groupIconURL,
    this.groupName,
    this.description,
  });

  final String groupIconURL;
  final String groupName;
  final String description;

  bool get isValid => groupIconURL != null && groupName != null && description != null;
}

class GroupItemCard extends StatelessWidget{
  GroupItemCard({ Key key, @required this.groupItem })
      : assert(groupItem != null && groupItem.isValid),
        super(key: key);

  final GroupItem groupItem;
  static const double height = 110.0;
  @override
  Widget build(BuildContext context){
    final ThemeData theme = Theme.of(context);
    final TextStyle titleStyle = theme.textTheme.headline.copyWith(color: Colors.black);
    final TextStyle descriptionStyle = theme.textTheme.subhead;

    return new Container(
      height: height,
      child: new Card(
        child: new Row(
          children: <Widget>[
            new Container(
              padding: const EdgeInsets.all(8.0),
              width: 85.0,
              height: 85.0,
              child: new ClipOval(
                child: new FadeInImage.assetNetwork(
                    //fit: BoxFit.fill,
                    placeholder: 'images/placeholderSquare.png',
                    image: groupItem.groupIconURL
                  ),
              ),
            ),
            new Expanded(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: new Text(
                      groupItem.groupName,
                      style: titleStyle,
                    ),
                  ),
                  new Padding(
                    padding: const EdgeInsets.only(bottom: 4.0, top: 4.0),
                    child: new Text(
                      groupItem.description, //MAX 51 Chars
                      style: descriptionStyle,
                    ),
                  ),
                ],
              ),
            ),
            new IconButton(
                icon: new Icon(Icons.chevron_right),
                onPressed: (){
                  Navigator.of(context).push(
                    new MaterialPageRoute(builder: (context) => new GroupPage(groupItem: groupItem)),
                  );
                }
            )
          ],
        ),
      ),
    );
  }

}



class groupsListBuilder extends StatefulWidget {
  @override
  _groupsListState createState() => new _groupsListState();
}

class _groupsListState extends State<groupsListBuilder>{
  @override
  Widget build(BuildContext context) {
    return new Scrollbar(
      child: new ListView(
        padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
        children: _getItems(),
      ),
    );
  }

  List <Widget> _getItems(){
    return groupsList.map((GroupItem groupItem) {
      return new Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        child: new GroupItemCard(
          groupItem: groupItem,
        ),
      );
    }).toList();

  }

}

List<GroupItem> groupsList = <GroupItem>[
  const GroupItem(
    groupIconURL: "https://thumbs.dreamstime.com/b/tooth-ready-to-fight-13579942.jpg",
    groupName: 'Cavity Fighters',
    description: "Fighting Cavities",
  ),
  const GroupItem(
    groupIconURL: "https://cdn1.vectorstock.com/i/1000x1000/74/55/cartoon-model-of-teeth-isolated-on-white-backgroun-vector-5837455.jpg",
    groupName: 'Gum Protectors',
    description: "Protecting Gum",
  ),
  const GroupItem(
    groupIconURL: "http://freedesignfile.com/upload/2017/04/Cartoon-teeth-with-toothbrush-vector.jpg",
    groupName: 'Brushes Group',
    description: "We love brushes",
  ),
  const GroupItem(
    groupIconURL: "https://st2.depositphotos.com/1742172/9683/v/950/depositphotos_96837112-stock-illustration-textured-cartoon-dental-floss.jpg",
    groupName: 'Flossing Boys',
    description: "Pls we're begging u floss",
  ),const GroupItem(
    groupIconURL: "https://thumbs.dreamstime.com/b/cartoon-tooth-gets-rid-yellow-plaque-enamel-cartoon-tooth-gets-rid-yellow-plaque-enamel-vector-illustration-106298614.jpg",
    groupName: 'Enamel Defenders',
    description: "This is the only dentist word I know",
  ),
  const GroupItem(
    groupIconURL: "https://i.imgur.com/BoN9kdC.png",
    groupName: 'Group 22',
    description: "Here is the description of the group again",
  ),
  const GroupItem(
    groupIconURL: "https://i.imgur.com/BoN9kdC.png",
    groupName: 'committee1',
    description: "Here is the description of the group again",
  ),
  const GroupItem(
    groupIconURL: "https://i.imgur.com/BoN9kdC.png",
    groupName: 'Group 22',
    description: "Here is the description of the group again",
  ),
];

