import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

import 'package:vos_supersales/core/database/app_database.dart';
import 'user_model.dart';
import 'package:vos_supersales/core/constants/api_constants.dart';

class UserService {


  /// 🌐 Fetch all users from API and store in local DB
  Future<void> seedUsersToDatabase() async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.users));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        final List<UserModel> users = data
            .map((json) => UserModel.fromJson(json))
            .toList();

        final db = await AppDatabase.instance.database;
        int insertedCount = 0;

        for (final user in users) {
          await db.insert(
            'users',
            user.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          insertedCount++;
        }

        print('✅ Users synced: $insertedCount');
      } else {
        print('❌ Failed to fetch users. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error syncing users: $e');
    }
  }

  /// 🔄 Save a list of users (used in AuthService or elsewhere)
  Future<void> saveUsers(List<UserModel> users) async {
    final db = await AppDatabase.instance.database;

    for (final user in users) {
      await db.insert(
        'users',
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    print('✅ Users saved to DB: ${users.length}');
  }

  /// 🔍 Get all local users
  Future<List<UserModel>> getAllUsers() async {
    final db = await AppDatabase.instance.database;
    final result = await db.query('users');
    return result.map((e) => UserModel.fromMap(e)).toList();
  }

  /// 🔐 Only allow login for Sales department
  Future<UserModel?> findUser(String email, String password) async {
    final db = await AppDatabase.instance.database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ? AND department_name = ?',
      whereArgs: [email, password, 'Sales'],
    );

    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }
    return null;
  }

  Future<void> seedUsersToDatabaseFromList(List<UserModel> users) async {}
}
