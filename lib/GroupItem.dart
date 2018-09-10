class GroupItem{
  const GroupItem({
    this.groupIconURL,
    this.groupName,
    this.description,
    this.password,
  });

  final String groupIconURL;
  final String groupName;
  final String description;
  final String password;

  bool get isValid => groupIconURL != null && groupName != null && description != null;
}