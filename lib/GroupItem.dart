class GroupItem{
  const GroupItem({
    this.groupIconURL,
    this.groupName,
    this.description,
    this.password,
    this.jUsers,
    this.headEmail,
    this.headName,
  });

  final String groupIconURL;
  final String groupName;
  final String description;
  final String password;
  final List<String> jUsers;
  final String headName;
  final String headEmail;

  bool get isValid => groupIconURL != null && groupName != null && description != null;
}