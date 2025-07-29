import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:vos_supersales/core/database/app_database.dart';
import 'package:vos_supersales/features/auth/login_screen.dart';
import 'package:vos_supersales/features/auth/user_service.dart';
import 'package:vos_supersales/features/auth/user_model.dart';
import 'package:vos_supersales/features/home/home_screen.dart';
import 'package:vos_supersales/features/sales/product/product_seeder.dart';
import 'package:vos_supersales/features/sales/salesman/salesman_service.dart';
import 'package:vos_supersales/features/sales/customer/customer_service.dart';
import 'package:vos_supersales/features/sales/invoice/sales_invoice_type_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final hasSeeded = prefs.getBool('hasSeededProducts') ?? false;

  // 🗂️ Init DB
  final db = await AppDatabase.instance.database;

  // 🧪 Reset + seed products if not seeded yet
  if (!hasSeeded) {
    await AppDatabase.deleteDb();
    await AppDatabase.instance.database;
    await seedProductsToDatabase(); // uses ProductService internally
    await prefs.setBool('hasSeededProducts', true);
    print("✅ Products seeded.");
  }

  // 🌐 Check internet
  final connectivityResult = await Connectivity().checkConnectivity();
  final hasInternet = connectivityResult != ConnectivityResult.none;

  // 🔁 Sync API data if online
  if (hasInternet) {
    try {
      await UserService().seedUsersToDatabase();
      await SalesmanService().seedSalesmenToDatabase();
      await CustomerService().fetchAndSeedCustomers();
      await SalesInvoiceTypeService().fetchInvoiceTypesFromApi(); // ⬅️ ADDED

      final users = await db.query('users');
      final salesmen = await db.query('salesmen');
      final customers = await db.query('customers');
      final invoiceTypes = await db.query('sales_invoice_types');

      print("✅ Users synced: ${users.length}");
      print("✅ Salesmen synced: ${salesmen.length}");
      print("✅ Customers synced: ${customers.length}");
      print("✅ Invoice Types synced: ${invoiceTypes.length}");
    } catch (e) {
      print("❌ Error syncing API data: $e");
    }
  } else {
    final localUsers = await db.query('users');
    final localSalesmen = await db.query('salesmen');
    final localCustomers = await db.query('customers');
    final invoiceTypes = await db.query('sales_invoice_types');

    print("⚠️ Offline: Loaded ${localUsers.length} users from local DB.");
    print("⚠️ Offline: Loaded ${localSalesmen.length} salesmen from local DB.");
    print("⚠️ Offline: Loaded ${localCustomers.length} customers from local DB.");
    print("⚠️ Offline: Loaded ${invoiceTypes.length} invoice types from local DB.");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('currentUser');

    if (userJson != null) {
      try {
        final userMap = jsonDecode(userJson);
        final user = UserModel.fromJson(userMap);
        if (user.departmentName.toLowerCase() == 'sales') {
          print("✅ Logged in as: ${user.fullName}");
          return HomeScreen(currentUser: user);
        } else {
          print("🚫 User not in Sales department.");
        }
      } catch (e) {
        print("❌ Error parsing saved user: $e");
      }
    }

    return const LoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VOS SuperSales',
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<Widget>(
        future: _getInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('❌ Startup error: ${snapshot.error}')),
            );
          } else {
            return snapshot.data!;
          }
        },
      ),
    );
  }
}
