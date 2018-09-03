
class UserSingleton {
  static final UserSingleton singleton = new UserSingleton._internal();
  String userID;
  String userEmail;
  String userPass;
  String userPriority;
  String userName;
  List<String> userCommittees;
  factory UserSingleton() {
    return singleton;
  }

  UserSingleton._internal();

}