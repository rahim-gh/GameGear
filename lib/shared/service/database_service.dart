import 'package:game_gear/shared/model/user_model.dart';
import 'package:game_gear/shared/utils/logger_util.dart';
import 'package:hive/hive.dart';
import 'package:logger/web.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  late Box<User> _userBox;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<void> initialize() async {
    try {
      _userBox = await Hive.openBox<User>('userBox');
      applog('Hive box "userBox" opened successfully.', level: Level.info);
    } catch (e) {
      applog('Error opening Hive box "userBox": $e', level: Level.error);
      rethrow;
    }
  }

  Future<int?> addUser(String fullname, String email, String password) async {
    try {
      await initialize();
      if (_userBox.values.any((user) => user.email == email)) {
        applog('User with email $email already exists.', level: Level.warning);
        return null; // User already exists
      }
      final int id = _userBox.length;
      final user = User(
        id: id,
        fullname: fullname,
        email: email,
        password: password,
      );
      await _userBox.add(user);
      applog('User with email $email added successfully.', level: Level.info);
      return id;
    } catch (e) {
      applog('Error adding user with email $email: $e', level: Level.error);
      rethrow;
    }
  }

  Future<User?> getUser(int id) async {
    try {
      await initialize();
      final user = _userBox.get(id);
      if (user != null) {
        applog('User with id $id retrieved successfully.', level: Level.info);
      } else {
        applog('User with id $id not found.', level: Level.warning);
      }
      return user;
    } catch (e) {
      applog('Error retrieving user with id $id: $e', level: Level.error);
      rethrow;
    }
  }

  Future<void> updateUser(
      int id, String fullname, String email, String password) async {
    try {
      await initialize();
      final user = User(
        id: id,
        fullname: fullname,
        email: email,
        password: password,
      );
      await _userBox.put(id, user);
      applog('User with id $id updated successfully.', level: Level.info);
    } catch (e) {
      applog('Error updating user with id $id: $e', level: Level.error);
      rethrow;
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      await initialize();
      await _userBox.delete(id);
      applog('User with id $id deleted successfully.', level: Level.info);
    } catch (e) {
      applog('Error deleting user with id $id: $e', level: Level.error);
      rethrow;
    }
  }

  Future<List<User>> getAllUsers() async {
    try {
      await initialize();
      final users = _userBox.values.toList();
      applog('Retrieved ${users.length} users.', level: Level.info);
      return users;
    } catch (e) {
      applog('Error retrieving all users: $e', level: Level.error);
      rethrow;
    }
  }
}
