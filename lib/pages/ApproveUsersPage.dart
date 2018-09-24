
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

class ApproveUsersPage extends StatefulWidget{
  _approveUsersPage createState() => new _approveUsersPage();
}

class _approveUsersPage extends State<ApproveUsersPage>{
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text("Users Awaiting Approval"),
      ),
      body: new SafeArea(
          top: false,
          bottom: false,
          child: new StreamBuilder(
              stream: Firestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: new CircularProgressIndicator());
                List<DocumentSnapshot> filtered = snapshot.data.documents;
                filtered.removeWhere((ds){
                  if(ds['rejected'] != null){
                    return true;
                  }
                  return ds['enabled'];
                });
                return new Scrollbar(
                    child: ListView.builder(
                        itemCount: filtered.length,
                        itemExtent: 60.0,
                        padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: new Text(filtered.elementAt(index)['fname'] + ' ' + filtered.elementAt(index)['lname']),
                            subtitle: new Text(filtered.elementAt(index)['email']),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                IconButton(icon: Icon(Icons.thumb_up), onPressed: (){
                                  CloudFunctions.instance.call(
                                    functionName: 'enableUser',
                                      parameters: <String, dynamic>{
                                        'uid': filtered.elementAt(index).documentID,
                                      },
                                  );
                                  Map<String, dynamic> data = new Map<String, dynamic>();
                                  data['enabled'] = true;
                                  Firestore.instance.collection('users').document(filtered.elementAt(index).documentID).setData(data, merge: true);
                                }),
                                IconButton(icon: Icon(Icons.thumb_down), onPressed: (){
                                  Map<String, dynamic> data = new Map<String, dynamic>();
                                  data['rejected'] = true;
                                  Firestore.instance.collection('users').document(filtered.elementAt(index).documentID).setData(data, merge: true);
                                }),
                              ],
                            ),
                          );
                        }
                    )
                );
              }
          )
      ),
    );
  }

}