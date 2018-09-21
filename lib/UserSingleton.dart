
import 'package:usdsa_proto/GroupItem.dart';

class UserSingleton {
  static final UserSingleton singleton = new UserSingleton._internal();
  String userID;
  String userEmail;
  String userPass;
  String userPriority;
  String userFName;
  String userLName;
  List<String> userCommittees;
  List<GroupItem> userCommitteesItems;
  factory UserSingleton() {
    return singleton;
  }

  UserSingleton._internal();

}