import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vos_supersales/features/auth/login_screen.dart';
import 'package:vos_supersales/features/auth/user_model.dart';
import 'sales_dashboard.dart';
import '../transactions/transactions_page.dart';
import '../home/reports_page.dart';
import 'package:vos_supersales/features/auth/global_salesman.dart';

class HomeScreen extends StatefulWidget {
  final UserModel currentUser;

  const HomeScreen({super.key, required this.currentUser});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    final salesman = GlobalSalesman.getSalesman();
    if (salesman != null) {
      debugPrint(
        "🧑‍💼 Logged in as: ${salesman.salesmanName}, ID: ${salesman.id}",
      );
    } else {
      debugPrint("❌ No salesman found in global context.");
    }
  }

  List<Widget> get pages => [
    SalesDashboard(currentUser: widget.currentUser),
    TransactionsPage(currentUser: widget.currentUser),
    ReportsPage(currentUser: widget.currentUser),
  ];

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUser');
    GlobalSalesman.clear();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTitle()),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Logout',
            ),
          ),
        ],
        backgroundColor: Colors.deepPurple.shade400,
        foregroundColor: Colors.white,
      ),
      body: IndexedStack(index: selectedIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => setState(() => selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.point_of_sale),
            label: 'Sales',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
        ],
      ),
    );
  }

  String getTitle() {
    switch (selectedIndex) {
      case 0:
        return 'Sales Dashboard';
      case 1:
        return 'Transactions';
      case 2:
        return 'Reports';
      default:
        return '';
    }
  }
}
