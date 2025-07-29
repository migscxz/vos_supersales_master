import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:vos_supersales/core/database/app_database.dart';
import 'package:vos_supersales/core/constants/api_constants.dart';
import 'salesman_model.dart';

class SalesmanService {
  final String _apiUrl = ApiConstants.salesmen;

  // 🌐 Fetch all salesmen from API and store to local SQLite
  Future<void> seedSalesmenToDatabase() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<SalesmanModel> salesmen = data
            .map((json) => SalesmanModel.fromJson(json))
            .toList();

        final db = await AppDatabase.instance.database;
        final batch = db.batch();

        for (final salesman in salesmen) {
          batch.insert(
            'salesmen',
            salesman.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        await batch.commit(noResult: true);
        print('✅ Salesmen synced to local DB: ${salesmen.length}');
      } else {
        print('❌ Failed to fetch salesmen. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error syncing salesmen from API: $e');
    }
  }

  // 🌐 ONLINE: Fetch salesman by employeeId from API
  Future<SalesmanModel?> getSalesmanByEmployeeId(int employeeId) async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        final matched = data.firstWhere(
              (json) => json['employeeId'] == employeeId,
          orElse: () => null,
        );

        if (matched != null) {
          return SalesmanModel.fromJson(matched);
        }

        print('⚠️ No salesman found online for employeeId: $employeeId');
        return null;
      } else {
        throw Exception('Failed to load salesmen. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching salesman online: $e');
      return null;
    }
  }

  // 📦 OFFLINE: Get salesman from local SQLite by employeeId
  Future<SalesmanModel?> getSalesmanFromLocalByEmployeeId(int employeeId) async {
    try {
      final db = await AppDatabase.instance.database;

      final result = await db.query(
        'salesmen',
        where: 'employee_id = ?',
        whereArgs: [employeeId],
        limit: 1,
      );

      if (result.isNotEmpty) {
        final salesman = SalesmanModel.fromMap(result.first);
        print('📦 Found local salesman: ${salesman.salesmanName}');
        return salesman;
      } else {
        print('⚠️ No local salesman found for employeeId: $employeeId');
        return null;
      }
    } catch (e) {
      print('❌ Error reading local salesman: $e');
      return null;
    }
  }
}
