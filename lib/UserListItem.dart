class GroupItem{
  const GroupItem({
    this.groupIconURL,
    this.groupName,
    this.description,
    this.password,
    this.jUsers
  });

  final String groupIconURL;
  final String groupName;
  final String description;
  final String password;
  final List<String> jUsers;

}