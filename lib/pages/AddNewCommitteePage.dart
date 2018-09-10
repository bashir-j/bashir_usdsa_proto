import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:usdsa_proto/GroupItem.dart';
import 'package:usdsa_proto/UserSingleton.dart';

class GroupItemCard extends StatelessWidget{
  GroupItemCard({ Key key, @required this.groupItem, this.registered })
      : assert(groupItem != null && groupItem.isValid),
        super(key: key);

  final GroupItem groupItem;
  final bool registered;
  static const double height = 110.0;
  UserSingleton userSing = new UserSingleton();

  @override
  Widget build(BuildContext context){
    final ThemeData theme = Theme.of(context);
    final TextStyle titleStyle = theme.textTheme.headline.copyWith(color: Colors.black);
    final TextStyle descriptionStyle = theme.textTheme.subhead;
    String enteredPass;

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
                child: CachedNetworkImage(
                  imageUrl: groupItem.groupIconURL,
                  placeholder: Image.asset('images/placeholderSquare.png'),
                ),
//                  child: new FadeInImage(
//                      //fit: BoxFit.fill,
//                      placeholder: 'images/placeholderSquare.png',
//                      image: new CachedNetworkImageProvider(groupItem.groupIconURL )
//                    ),
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
            registered ? new IconButton(
                icon: new Icon(Icons.remove, color: Colors.red, size: 32.0,),
                onPressed: ()async {
                  final ios = Theme.of(context).platform == TargetPlatform.iOS;
                  showDialog(context: context, builder: (BuildContext context){
                    if (!ios) {
                      return new AlertDialog(
                          title: new Text("Remove Committee"),
                          content: new Text("Are you sure you would like to remove this committee? This cannot be undone, you will need to reenter the committee password."),
                          actions: <Widget>[
                            new FlatButton(onPressed: (){
                              Navigator.of(context).pop();
                            },
                                child: new Text("Cancel")
                            ),
                            new FlatButton(onPressed: (){
                              deleteCommittee(context);
                            },
                                child: new Text("Delete"),
                              textColor: Colors.red,
                            ),
                          ]
                      );
                    } else {
                      return new CupertinoAlertDialog(
                          title: new Text("Remove Committee"),
                          content: new Text("Are you sure you would like to remove this committee? This cannot be undone, you will need to reenter the committee password."),
                          actions: <Widget>[
                            new CupertinoDialogAction(onPressed: (){
                              Navigator.of(context).pop();
                            },
                                child: new Text("Cancel")
                            ),
                            new CupertinoDialogAction(onPressed: (){
                              deleteCommittee(context);
                            },
                                child: new Text("Delete"),
                              isDestructiveAction: true,
                            ),
                          ]
                      );
                    }
                  });
                  //addCommitteee(context);
                }

            ) :
            new IconButton(
                icon: new Icon(Icons.add),
                onPressed: ()async {
                  final ios = Theme.of(context).platform == TargetPlatform.iOS;
                  showDialog(context: context, builder: (BuildContext context){
                    if (!ios) {
                      return new AlertDialog(
                        title: new Text("Enter Committee Password"),
                        content: new TextField(
                          onChanged: (String text) {
                            enteredPass = text;
                          },
                        ),
                        actions: <Widget>[
                          new FlatButton(onPressed: (){
                            Navigator.of(context).pop();
                          },
                          child: new Text("Cancel")
                          ),
                          new FlatButton(onPressed: (){
                            if(enteredPass == groupItem.password){
                              addCommitteee(context);
                            }else{
                              Navigator.of(context).pop();
                              showDialog(context: context, builder: (BuildContext context){
                                return new AlertDialog(
                                  title: new Text("Incorrect Password Entered"),
                                  content: new Text("Please make sure the password is correct and try again"),
                                  actions: <Widget>[
                                    new FlatButton(onPressed: (){
                                      Navigator.of(context).pop();
                                    },
                                        child: new Text("Dismiss")
                                    ),
                                  ],
                                );
                              });
                            }
                          },
                          child: new Text("Submit")
                          ),
                        ]
                      );
                    } else {
                      return Dialog(
                        child: new CupertinoAlertDialog(
                            title: new Text("Enter Committee Password"),
                            content: new TextField(
                              decoration: null,
                              onChanged: (String text) {
                                enteredPass = text;
                              },
                            ),
                            actions: <Widget>[
                              new CupertinoDialogAction(onPressed: (){
                                Navigator.of(context).pop();
                              },
                                  child: new Text("Cancel")
                              ),
                              new CupertinoDialogAction(onPressed: (){
                                if(enteredPass == groupItem.password){
                                  addCommitteee(context);
                                }else{
                                  Navigator.of(context).pop();
                                  showDialog(context: context, builder: (BuildContext context){
                                    return new CupertinoAlertDialog(
                                      title: new Text("Incorrect Password Entered"),
                                      content: new Text("Please make sure the password is correct and try again"),
                                      actions: <Widget>[
                                        new CupertinoDialogAction(onPressed: (){
                                          Navigator.of(context).pop();
                                        },
                                            child: new Text("Dismiss")
                                        ),
                                      ],
                                    );
                                  });
                                }
                              },
                                  child: new Text("Submit"),
                                isDefaultAction: true,
                              ),
                            ]
                        ),
                      );
                    }
                  });
                  //addCommitteee(context);
                }
            )
          ],
        ),
      ),
    );
  }

  deleteCommittee(BuildContext context)async {
    showDialog(context: context,
        barrierDismissible: false,
        builder: (context){
          return Center(
            child: Container(child: new CircularProgressIndicator()
            ),
          );
        }
    );
    Map<String, dynamic> dataMap = new Map<String, dynamic>();
    userSing.userCommittees.remove(groupItem.groupName);
    dataMap['rCommittees'] = userSing.userCommittees;
    await Firestore.instance.collection('users')
        .document(userSing.userID)
        .setData(dataMap, merge: true);
    userSing.userCommitteesItems.removeWhere((gI){
      return gI.groupName == groupItem.groupName;
    });
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pop(context);
  }
  addCommitteee(BuildContext context)async {
    showDialog(context: context,
        barrierDismissible: false,
        builder: (context){
          return Center(
            child: Container(child: new CircularProgressIndicator()
            ),
          );
        }
    );
    Map<String, dynamic> dataMap = new Map<String, dynamic>();
    userSing.userCommittees.add(groupItem.groupName);
    dataMap['rCommittees'] = userSing.userCommittees;
    await Firestore.instance.collection('users')
        .document(userSing.userID)
        .setData(dataMap, merge: true);
    DocumentSnapshot cds = await Firestore.instance
        .collection('committees')
        .document(groupItem.groupName)
        .get();
    userSing.userCommitteesItems.add(
        new GroupItem(
          groupName: cds['name'],
          description: cds['description'],
          groupIconURL: cds['iconUrl'],
          password: cds['password'],
        )
    );
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pop(context);
  }

}

class AddNewCommitteePage extends StatefulWidget{
  @override
  _AddCommitteePageState createState() => new _AddCommitteePageState();
}

class _AddCommitteePageState extends State<AddNewCommitteePage>{
  UserSingleton userSing = new UserSingleton();
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text("Add/Remove Committees"),
      ),
      body: new SafeArea(
        top: false,
        bottom: false,
        child: new StreamBuilder(
            stream: Firestore.instance.collection('committees').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Center(child: new CircularProgressIndicator());
              return new Scrollbar(
                  child: new ListView.builder(
                      itemCount: snapshot.data.documents.length,
                      itemExtent: GroupItemCard.height,
                      padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                      itemBuilder: (context, index){
                        DocumentSnapshot ds = snapshot.data.documents[index];
                        GroupItem snapshotToItem = new GroupItem(
                            groupName: ds['name'],
                            groupIconURL: ds['iconUrl'],
                            description: ds['description'],
                            password: ds['password'],
                        );
                        bool reg = userSing.userCommittees.contains(snapshotToItem.groupName);
                        return new Container(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          child: new GroupItemCard(
                            groupItem: snapshotToItem,
                            registered: reg,
                          ),
                        );
                      }
                  )
              );
            }
        ),
      ),
    );
  }
}