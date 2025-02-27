import 'package:game_gear/shared/model/user_model.dart';
import 'package:hive/hive.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  late Box<User> _userBox;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<void> initialize() async {
    _userBox = await Hive.openBox<User>('userBox');
  }

  Future<int> addUser(String fullname, String email, String password) async {
    await initialize(); // Ensure initialization is complete
    final int id = _userBox.length;
    final user = User(
      id: id,
      fullname: fullname,
      email: email,
      password: password,
    );
    await _userBox.add(user);
    return id;
  }

  Future<User?> getUser(int id) async {
    await initialize(); // Ensure initialization is complete
    return _userBox.get(id);
  }

  Future<void> updateUser(
      int id, String fullname, String email, String password) async {
    await initialize(); // Ensure initialization is complete
    final user = User(
      id: id,
      fullname: fullname,
      email: email,
      password: password,
    );
    await _userBox.put(id, user);
  }

  Future<void> deleteUser(int id) async {
    await initialize(); // Ensure initialization is complete
    await _userBox.delete(id);
  }
}
