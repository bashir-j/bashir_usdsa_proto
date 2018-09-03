import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'CustomAddNewsItem.dart';

class NewsItem {
  const NewsItem({
    this.newsImgUrl,
    this.title,
    this.description,
    this.date,
  });

  final String newsImgUrl;
  final String title;
  final String description;
  final String date;

  bool get isValid => newsImgUrl != null && title != null && description != null && date != null;
}



class NewsItemCard extends StatelessWidget {
  NewsItemCard({ Key key, @required this.newsItem })
      : assert(newsItem != null && newsItem.isValid),
        super(key: key);

  static const double height = 400.0;
  final NewsItem newsItem;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle titleStyle = theme.textTheme.headline.copyWith(color: Colors.black);
    final TextStyle descriptionStyle = theme.textTheme.subhead;

    return new SafeArea(
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
              bottomLeft: const Radius.circular(2.0),
              bottomRight: const Radius.circular(2.0),
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
                        image: new NetworkImage(newsItem.newsImgUrl),
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
              new ButtonTheme.bar(
                child: new ButtonBar(
                  alignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new FlatButton(
                      child: const Text('SHARE'),
                      textColor: theme.buttonColor,
                      onPressed: () { /* do nothing */ },
                    ),
                    new FlatButton(
                      child: const Text('EXPLORE'),
                      textColor: theme.buttonColor,
                      onPressed: () { /* do nothing */ },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: new AppBar(
        titleSpacing: 0.0,
        title: new Text("Announcements",overflow: TextOverflow.fade),
        actions: <Widget>[
          new IconButton(icon: Icon(Icons.add), onPressed: (){
            Navigator.push(
              context,
              new MaterialPageRoute(builder: (context) => new CustomAddNewsItemPage(committeeName: widget.committeeName,)),
            );
          }),
        ],
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
                        newsImgUrl: ds['newsImgUrl'],
                        date: format.format(dt),
                        title: ds['title'],
                        description: ds['description']
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


