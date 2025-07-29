import 'package:flutter/material.dart';
import 'package:vos_supersales/features/auth/global_user.dart';
import 'package:vos_supersales/features/home/home_screen.dart';
import '../../core/theme/app_theme.dart';
import 'auth_service.dart';
import 'user_model.dart';
import 'package:vos_supersales/features/sales/salesman/salesman_service.dart';
import 'package:vos_supersales/features/auth/global_salesman.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _inputBorder = const OutlineInputBorder(
    borderSide: BorderSide(color: AppColors.grey),
    borderRadius: BorderRadius.all(Radius.circular(12)),
  );

/* <<<<<<<<<<<<<<  ✨ Windsurf Command 🌟 >>>>>>>>>>>>>>>> */
  void _submitLogin() async {
    _emailController.text = 'wilmar_bautista@men2corp.com';
    _passwordController.text = 'wilmar123';
    //_emailController.text = 'davewilmoreduran@men2corp.com';//
    //_passwordController.text = 'dave123';//
/* <<<<<<<<<<  e76cf1f9-b381-49bc-a3d0-9d85bc17d5ed  >>>>>>>>>>> */

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await AuthService().login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;
      Navigator.pop(context); // hide loader

      if (result is UserModel) {
        if (result.departmentName.toLowerCase() == 'sales') {
          final localSalesman = await SalesmanService()
              .getSalesmanFromLocalByEmployeeId(result.userId);

          if (localSalesman != null) {
            GlobalSalesman.setSalesman(localSalesman);
            GlobalUser.setUser(result);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => HomeScreen(currentUser: result),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No salesman record found locally.'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Access denied: You are not part of the Sales department.',
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } else if (result is String) {
        ScaffoldMessenger.of(context).showSnackBar(
          // ignore: cast_from_null_always_fails
          SnackBar(
            // ignore: cast_from_null_always_fails
            content: Text(result as String),
            backgroundColor: Colors.redAccent,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid email or password'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email',
            labelStyle: const TextStyle(color: AppColors.accentBlack),
            prefixIcon: const Icon(
              Icons.email_outlined,
              color: AppColors.accentBlack,
            ),
            focusedBorder: _inputBorder,
            enabledBorder: _inputBorder,
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            labelStyle: const TextStyle(color: AppColors.accentBlack),
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: AppColors.accentBlack,
            ),
            focusedBorder: _inputBorder,
            enabledBorder: _inputBorder,
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Login',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
