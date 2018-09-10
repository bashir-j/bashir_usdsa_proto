import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:usdsa_proto/GroupItem.dart';
import 'GroupsList.dart';
import 'CustomNewsStream.dart';
import '../group_options_icons_icons.dart';

class GroupOption{
  const GroupOption({
    this.optionIcon,
    this.optionName,
    this.description,
  });

  final IconData optionIcon;
  final String optionName;
  final String description;

  bool get isValid => optionIcon != null && optionName != null && description != null;
}

class GroupOptionItemCard extends StatelessWidget{
  GroupOptionItemCard({ Key key, @required this.groupOption, @required this.groupItemName })
      : assert(groupOption != null && groupOption.isValid && groupItemName != null),
        super(key: key);

  final GroupOption groupOption;
  final String groupItemName;

  static const double height = 110.0;
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle titleStyle = theme.textTheme.headline.copyWith(color: Colors.black);
    final TextStyle descriptionStyle = theme.textTheme.subhead;
    return new Container(
      height: height,
      child: new Card(
        child: new Row(
          children: <Widget>[
            new Container(
              padding: const EdgeInsets.only(left: 8.0, right: 32.0, top: 4.0 ,bottom: 4.0),
              child: new Icon(groupOption.optionIcon, size: 85.0,),
            ),
            new Expanded(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: new Text(
                      groupOption.optionName,
                      style: titleStyle,
                    ),
                  ),
                  new Padding(
                    padding: const EdgeInsets.only(bottom: 4.0, top: 4.0),
                    child: new Text(
                      groupOption.description, //MAX 51 Chars
                      style: descriptionStyle,
                    ),
                  ),
                ],
              ),
            ),
            new IconButton(
                icon: new Icon(Icons.chevron_right),
                onPressed: (){
                  if(groupOption == groupsOptionsList[0]){
                    Navigator.push(
                      context,
                      new MaterialPageRoute(builder: (context) => new customNewsStreamBuilder(committeeName: groupItemName)),
                    );
                  }else if (groupOption == groupsOptionsList[1]){

                  }
                  else if (groupOption == groupsOptionsList[2]){

                  }
                  else{

                  }
                }
            )
          ],
        ),
      ),
    );
  }

}



class _groupOptionsBuilder extends StatelessWidget{
  _groupOptionsBuilder({ Key key, @required this.groupItemName })
      : assert(groupItemName != null),
        super(key: key);

  final String groupItemName;

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
    return groupsOptionsList.map((GroupOption groupOption) {
      return new Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        child: new GroupOptionItemCard(
          groupOption: groupOption,
          groupItemName: groupItemName,
        ),
      );
    }).toList();

  }

}


class GroupPage extends StatefulWidget {

  GroupPage({@required this.groupItem});
  final GroupItem groupItem;

  @override
  _GroupPageState createState() => new _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(

        title: new Row(
          children: <Widget>[
//            new LayoutBuilder(
//              builder: (BuildContext context, BoxConstraints constraints) {
//                return new Container(
//                  padding: const EdgeInsets.all(4.0),
//                  width: constraints.maxHeight,
//                  height: constraints.maxHeight,
//                  child: new Container(
//                    decoration: new BoxDecoration(
//                        shape: BoxShape.circle,
//                        image: new DecorationImage(
//                            fit: BoxFit.fill,
//                            image: new NetworkImage(widget.groupItem.groupIconURL)
//                        )
//                    ),
//                  ),
//
//                );
//              },
//
//            ),
            new Text(widget.groupItem.groupName),
          ],
        ),

      ),
      body: new _groupOptionsBuilder(groupItemName: widget.groupItem.groupName,),
    );
  }
}

final List<GroupOption> groupsOptionsList = <GroupOption>[
  const GroupOption(
    optionIcon: GroupOptionsIcons.newspaper,
    optionName: 'Announcements',
    description: "View all announcements from this committee",
  ),
  const GroupOption(
    optionIcon: IconData(0xe800, fontFamily: 'GroupOptionsIcons'),
    optionName: 'Meetings',
    description: "View all meetings held by this committee",
  ),
  const GroupOption(
    optionIcon: Icons.info,
    optionName: 'Committee Info',
    description: "View information about this group",
  ),
];