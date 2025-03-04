class User {
  final String uid;
  final String fullname;
  final String email;
  final String password;
  final bool isShopOwner;

  User({
    required this.uid,
    required this.fullname,
    required this.email,
    required this.password,
    this.isShopOwner = false,
  });

  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      uid: data['uid'],
      fullname: data['fullname'],
      email: data['email'],
      password: data['password'],
      isShopOwner: data['isShopOwner'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullname': fullname,
      'email': email,
      'password': password,
      'isShopOwner': isShopOwner,
    };
  }

  @override
  String toString() {
    return 'User{id: $uid, fullname: $fullname, email: $email, password: $password, isShopOwner: $isShopOwner}';
  }
}
