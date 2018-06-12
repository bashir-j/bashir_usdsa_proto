import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class NewsItem {
  const NewsItem({
    this.newsImgUrl,
    this.title,
    this.description,
  });

  final String newsImgUrl;
  final String title;
  final List<String> description;

  bool get isValid => newsImgUrl != null && title != null && description?.length == 3;
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
                            newsItem.description[0],
                            style: descriptionStyle.copyWith(color: Colors.black54),
                          ),
                        ),
                        new Text(newsItem.description[1]),
                        new Text(newsItem.description[2]),
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

class newsStreamBuilder extends StatefulWidget{
  @override
  _newsStreamState createState() => new _newsStreamState();

}

class _newsStreamState extends State<newsStreamBuilder>{
  List<NewsItem> newsItemsVar = newsItems;

  @override
  Widget build(BuildContext context) {
    return new RefreshIndicator(
      child: new Scrollbar(
        child: new ListView(
          itemExtent: NewsItemCard.height,
          padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
          children: _getItems(),
        ),
      ),
      onRefresh: _handleRefresh,
    );
  }

  List <Widget> _getItems(){
    return newsItemsVar.map((NewsItem newsItem) {
      return new Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        child: new NewsItemCard(
          newsItem: newsItem,
        ),
      );
    }).toList();

  }

  Future<Null> _handleRefresh() async {
    await new Future.delayed(new Duration(seconds: 3));
    DateTime now = new DateTime.now();
    String RN = now.day.toString() + "/" + now.month.toString() + "/" + now.year.toString();
    setState(() {
      newsItemsVar.insert(0, new NewsItem(
        newsImgUrl: 'https://scontent.fdxb1-1.fna.fbcdn.net/v/t1.0-9/12011243_672725346196991_1028186721404886201_n.png?_nc_cat=0&oh=53eb7559edf322d8f0f2ec6c48eb844d&oe=5BBD7594',
        title: 'Thank You For Refreshing',
        description: <String>[
           RN ,
          'Here is Your New News',
          'Suck it Wazzan',
        ]
      ));
    });

    return null;
  }
}





final List<NewsItem> newsItems = <NewsItem>[
  const NewsItem(

    newsImgUrl: 'https://media.licdn.com/dms/image/C5103AQEPp9mDv936Jg/profile-displayphoto-shrink_200_200/0?e=1533772800&v=beta&t=lTXiz7gBdrxvUaPnk0BJOHUoTqQZ9uWSSA__kS-IVeY',
    title: 'New President Announced',
    description: const <String>[
      '6/7/2018',
      'His Name Is Bashir Jarrah',
      'Suck it Wazzan',
    ],
  ),
  const NewsItem(
    newsImgUrl: 'https://scontent.fdxb1-1.fna.fbcdn.net/v/t1.0-9/31091883_1209379352531585_3860564549811830784_n.jpg?_nc_cat=0&oh=f3b2f6bdcb14ed7f9a283e0a8c71550d&oe=5BBBFB8E',
    title: 'Old President Impeached',
    description: const <String>[
      '1/7/2018',
      'He Spent All Our Money On This Stupid App',
      'What A Loser',
    ],
  )
];


