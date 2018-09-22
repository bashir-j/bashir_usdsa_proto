import 'dart:async';
import 'dart:convert';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:usdsa_proto/Secrets.dart';
import 'package:usdsa_proto/UserSingleton.dart';
import 'CustomAddNewsItem.dart';

class NewsItem {
  const NewsItem({
    this.newsImgUrl,
    this.title,
    this.description,
    this.date,
    this.docID,
    this.imgRef,
    this.commName,
  });

  final String newsImgUrl;
  final String title;
  final String description;
  final String date;
  final String docID;
  final String imgRef;
  final String commName;
  bool get isValid => newsImgUrl != null && title != null && description != null && date != null && docID != null;
}



class NewsItemCard extends StatelessWidget {
  NewsItemCard({ Key key, @required this.newsItem })
      : assert(newsItem != null && newsItem.isValid),
        super(key: key);

  static const double height = 350.0;
  final NewsItem newsItem;
  List<String> popupOptions = <String>["Send Notification","Delete"];
  TapDownDetails details;
  UserSingleton userSing = new UserSingleton();
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle titleStyle = theme.textTheme.headline.copyWith(color: Colors.black);
    final TextStyle descriptionStyle = theme.textTheme.subhead;

    return GestureDetector(
      onTapDown: (newDetails){
        details = newDetails;
      },
      onLongPress: (){
        if(userSing.userPriority == '2'){
          menuPrompt(context);
        }
      },
      child: new SafeArea(
        top: false,
        bottom: false,
        child: new Container(
          padding: const EdgeInsets.all(8.0),
          height: height,
          child: new Card(
            shape: const RoundedRectangleBorder(
              borderRadius: const BorderRadius.only(
                topLeft: const Radius.circular(16.0),
                topRight: const Radius.circular(16.0),
                bottomLeft: const Radius.circular(16.0),
                bottomRight: const Radius.circular(16.0),
              ),
            ),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // photo and title
                new SizedBox(
                  height: 184.0,
                  child: new Stack(
                    children: <Widget>[
                      new Positioned.fill(
                        child: new Image(
                          image: new CachedNetworkImageProvider(newsItem.newsImgUrl),
                          fit: BoxFit.cover,
                        ),
                      ),

                    ],
                  ),
                ),
                // description and share/explore buttons
                new Expanded(
                  child: new Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                    child: new DefaultTextStyle(
                      softWrap: false,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: descriptionStyle,
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: new Text(newsItem.title,
                              style: titleStyle,
                            ),
                          ),
                          // three line description
                          new Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: new Text(
                              newsItem.date,
                              style: descriptionStyle.copyWith(color: Colors.black54),
                            ),
                          ),
                          new Text(newsItem.description),
                        ],
                      ),
                    ),
                  ),
                ),
                // share, explore buttons
//              new ButtonTheme.bar(
//                child: new ButtonBar(
//                  alignment: MainAxisAlignment.start,
//                  children: <Widget>[
//                    new FlatButton(
//                      child: const Text('SHARE'),
//                      textColor: theme.buttonColor,
//                      onPressed: () { /* do nothing */ },
//                    ),
//                    new FlatButton(
//                      child: const Text('EXPLORE'),
//                      textColor: theme.buttonColor,
//                      onPressed: () { /* do nothing */ },
//                    ),
//                  ],
//                ),
//              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  menuPrompt(BuildContext cont) async{
    Secret secret = await SecretLoader(secretPath: "secrets.json").load();

    //RenderBox box = cont.findRenderObject();
    Offset of = details.globalPosition;
    print(of.dx.toString() + ' ' + of.dy.toString());
    String sel = await showMenu<String>(
        position: new RelativeRect.fromLTRB(of.dx, of.dy, 100.0, 100.0),
        context: cont,
        items: popupOptions.map((option){
          return new PopupMenuItem<String>(
            child: new Text(option),
            value: option,
          );
        }).toList()
    );
    if (sel != null) {
      switch(sel){
        case "Send Notification":{
          String notifBody = newsItem.description;
//          if(notifBody.length > 60) {
//            notifBody = notifBody.substring(0, 60);
//            notifBody = notifBody + '...';
//          }

          print("edi");
          Map<String, String> headers = {
            'Content-type' : 'application/json',
            'Authorization': secret.apiKey,
          };
          Map<String, String> notif = {
            'sound': 'default',
            'badge': '1',
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
            "to": "/topics/"+newsItem.commName.replaceAll(' ', '')
          };
          var vBody = jsonEncode(body);
          Response resp = await post(
            Uri.encodeFull("https://fcm.googleapis.com/fcm/send"),
            headers: headers,
            body: vBody,
          );
          print(resp.body);
        }
        break;
        case "Delete":{

          print("del attempt");
          if(newsItem.imgRef != null){
            print("del");
            Firestore.instance.collection("committees").document(newsItem.commName).collection('announcements').document(newsItem.docID).delete();
            FirebaseStorage.instance.ref().child(newsItem.imgRef).delete();
          }else{
            String ref = newsItem.newsImgUrl;
            ref = ref.split("/images%2F").elementAt(1);
            ref = ref.split("?alt=").elementAt(0);
            ref = ref.replaceAll("%20", " ");
            ref = ref.replaceAll("%3A", ":");
            print(ref);
            Firestore.instance.collection("committees").document(newsItem.commName).collection('announcements').document(newsItem.docID).delete();
            FirebaseStorage.instance.ref().child("images/"+newsItem.commName+'/'+ref).delete();
          }

        }
        break;
        default:{

        }
        break;
      }
    }
  }
}

class customNewsStreamBuilder extends StatefulWidget{
  customNewsStreamBuilder({@required this.committeeName});
  final String committeeName;
  
  @override
  _customNewsStreamState createState() => new _customNewsStreamState();

}

class _customNewsStreamState extends State<customNewsStreamBuilder>{
  //List<NewsItem> newsItemsVar = newsItems;
  UserSingleton userSing = new UserSingleton();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        titleSpacing: 0.0,
        title: new Text("Announcements",overflow: TextOverflow.fade),
        actions: userSing.userPriority == '2' ? <Widget>[
          new IconButton(icon: Icon(Icons.add), onPressed: (){
            Navigator.push(
              context,
              new MaterialPageRoute(builder: (context) => new CustomAddNewsItemPage(committeeName: widget.committeeName,)),
            );
          }),
        ] : null,
      ),
      body: new StreamBuilder(
          stream: Firestore.instance.collection('committees').document(widget.committeeName).collection('announcements').orderBy("date", descending: true).snapshots(),
          builder: (context, snapshot){
            if (!snapshot.hasData) return Center(child: new CircularProgressIndicator());
            return new Scrollbar(
                child: new ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemExtent: NewsItemCard.height,
                    padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                    itemBuilder: (context, index){
                      DocumentSnapshot ds = snapshot.data.documents[index];
                      DateTime dt = ds['date'];
                      final format = new DateFormat('dd-MM-yyyy');
                      NewsItem snapshotToItem = new NewsItem(
                        commName: widget.committeeName,
                        docID: ds.documentID,
                        newsImgUrl: ds['newsImgUrl'],
                        date: format.format(dt),
                        title: ds['title'],
                        description: ds['description'],
                        imgRef: ds['imgRef']
                      );
                      return new Container(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        child: new NewsItemCard(
                          newsItem: snapshotToItem,
                        ),
                      );
                    }
                )
            );
          }
      ),
    );
  }


//  @override
//  Widget build(BuildContext context) {
//    return new Scrollbar(
//      child: new ListView(
//        itemExtent: NewsItemCard.height,
//        padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
//        children: _getItems(),
//      ),
//    );
//  }
//



}





//final List<NewsItem> newsItems = <NewsItem>[
//  const NewsItem(
//
//    newsImgUrl: 'https://media.licdn.com/dms/image/C5103AQEPp9mDv936Jg/profile-displayphoto-shrink_200_200/0?e=1533772800&v=beta&t=lTXiz7gBdrxvUaPnk0BJOHUoTqQZ9uWSSA__kS-IVeY',
//    title: 'New President Announced',
//    description: const <String>[
//      '6/7/2018',
//      'His Name Is Bashir Jarrah',
//      'Suck it Wazzan',
//    ],
//  ),
//  const NewsItem(
//    newsImgUrl: 'https://scontent.fdxb1-1.fna.fbcdn.net/v/t1.0-9/31091883_1209379352531585_3860564549811830784_n.jpg?_nc_cat=0&oh=f3b2f6bdcb14ed7f9a283e0a8c71550d&oe=5BBBFB8E',
//    title: 'Old President Impeached',
//    description: const <String>[
//      '1/7/2018',
//      'He Spent All Our Money On This Stupid App',
//      'What A Loser',
//    ],
//  )
//];


