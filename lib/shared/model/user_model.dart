class User {
  final String uid;
  final String fullName;
  final String email;
  final String password;
  final bool isShopOwner;
  final String? imageBase64;

  User({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.password,
    this.isShopOwner = false,
    this.imageBase64,
  });

  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      uid: data['uid'],
      fullName: data['fullName'],
      email: data['email'],
      password: data['password'],
      isShopOwner: data['isShopOwner'] ?? false,
      imageBase64: data['imageBase64'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'password': password,
      'isShopOwner': isShopOwner,
      'imageBase64': imageBase64,
    };
  }

  @override
  String toString() {
    return 'User{uid: $uid, fullName: $fullName, email: $email, password: $password, isShopOwner: $isShopOwner, imageBase64: $imageBase64}';
  }
}
