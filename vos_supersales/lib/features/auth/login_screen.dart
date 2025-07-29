import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/database/app_database.dart';

import 'login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> _printAllUsersFromDb() async {
    final db = await AppDatabase.instance.database;
    final users = await db.query('users');

    if (users.isEmpty) {
      debugPrint('⚠️ No users found in the database.');
    } else {
      for (var user in users) {
        debugPrint(
          '🔍 USER: ${user['fullName']} | ${user['email']} | ${user['departmentName']}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Welcome Back',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: AppColors.textFill),
              ),
              const SizedBox(height: 32),
              const LoginForm(),
              const SizedBox(height: 32),
              if (kDebugMode)
                TextButton(
                  onPressed: _printAllUsersFromDb,
                  child: const Text(
                    'Developer Tools',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
