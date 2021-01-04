class User {
  String id;
  String name;
  String email;
  bool emailVerified;
  bool added;
  int createdAt;

  User.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    email = map['email'];
    emailVerified = map['emailVerified'];
    added = map['added'];
    createdAt = map['createdAt'];
  }
}
