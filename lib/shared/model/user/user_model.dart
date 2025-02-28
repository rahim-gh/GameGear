import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class User {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String fullname;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String password;

  @HiveField(4)
  final bool isShopOwner;

  User({
    required this.id,
    required this.fullname,
    required this.email,
    required this.password,
    this.isShopOwner = false,
  });

  @override
  String toString() {
    return 'User{id: $id, fullname: $fullname, email: $email, password: $password, isShopOwner: $isShopOwner}';
  }
}
