import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import '../../../core/database/app_database.dart';
import 'customer_model.dart';
import 'package:vos_supersales/core/constants/api_constants.dart';

class CustomerService {
  /// Fetch customers from API and insert into local DB if not yet existing
  Future<void> fetchAndSeedCustomers() async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.customers));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final db = await AppDatabase.instance.database;

        for (final json in data) {
          final customer = Customer.fromJson(json);

          final existing = await db.query(
            'customers',
            where: 'customerCode = ?',
            whereArgs: [customer.customerCode],
          );

          if (existing.isEmpty) {
            await db.insert('customers', customer.toMap());
          }
        }

        print('✅ Customers seeded successfully.');
      } else {
        print('❌ Failed to fetch customers. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching customers: $e');
    }
  }

  /// Insert a customer directly into local DB
  Future<void> insertCustomerToLocalDb(Customer customer) async {
    final db = await AppDatabase.instance.database;
    await db.insert('customers', customer.toMap());
    print('📦 Local insert: ${customer.customerName}');
  }

  /// Sync a single customer to the API
  Future<bool> syncSingleCustomer(Customer customer) async {
    final db = await AppDatabase.instance.database;

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.createCustomer),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(customer.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await db.update(
          'customers',
          {
            'isSynced': 1,
            'syncedAt': DateTime.now().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [customer.id],
        );
        print('✅ Synced customer: ${customer.customerName}');
        return true;
      } else {
        print('❌ Failed to sync customer ${customer.customerName}. Status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error syncing customer ${customer.customerName}: $e');
      return false;
    }
  }

  /// Sync all unsynced customers
  Future<void> syncUnsyncedCustomers() async {
    final db = await AppDatabase.instance.database;
    final unsynced = await db.query('customers', where: 'isSynced = ?', whereArgs: [0]);

    for (final json in unsynced) {
      try {
        final customer = Customer.fromJson(json);
        final success = await syncSingleCustomer(customer);
        if (!success) {
          print('⚠️ Sync failed for customer: ${customer.customerName}');
        }
      } catch (e) {
        print('❌ Failed to parse or sync customer: $e');
      }
    }
  }

  /// Get all customers from local DB
  Future<List<Customer>> getAllCustomers() async {
    final db = await AppDatabase.instance.database;
    final result = await db.query('customers', orderBy: 'customerName ASC');
    return result.map((e) => Customer.fromJson(e)).toList();
  }
}
