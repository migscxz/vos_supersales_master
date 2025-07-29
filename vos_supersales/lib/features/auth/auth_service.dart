import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vos_supersales/features/auth/user_model.dart';
import 'package:vos_supersales/features/auth/user_service.dart';
import 'package:vos_supersales/core/constants/api_constants.dart';

class AuthService {


  /// 🌐 Fetch users from API and sync to local DB.
  Future<List<UserModel>> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.users));
      print('🌐 API Response Status: ${response.statusCode}');
      print('📥 Raw API Response: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final users = data.map((json) => UserModel.fromJson(json)).toList();

        // Save only active users from Sales department to SQLite
        final salesUsers = users
            .where(
              (u) => u.isActive && u.departmentName.toLowerCase() == 'sales',
            )
            .toList();

        await UserService().seedUsersToDatabaseFromList(salesUsers);

        print('✅ Synced ${salesUsers.length} Sales users to local DB');
        return salesUsers;
      } else {
        throw Exception('Server error ${response.statusCode}');
      }
    } catch (e) {
      print('❌ API fetch failed: $e');
      final localUsers = await UserService().getAllUsers();
      print('📦 Loaded ${localUsers.length} users from local DB');
      if (localUsers.isNotEmpty) return localUsers;
      throw Exception('No users available offline.');
    }
  }

  /// 🔐 Login using local SQLite DB only.
  Future<UserModel?> login(String email, String password) async {
    final user = await UserService().findUser(email, password);

    if (user != null) {
      if (user.departmentName.toLowerCase() == 'sales') {
        print("✅ Login success: ${user.fullName}");
        return user;
      } else {
        throw Exception('Access denied: Not in Sales department.');
      }
    } else {
      throw Exception('Invalid email or password.');
    }
  }
}
