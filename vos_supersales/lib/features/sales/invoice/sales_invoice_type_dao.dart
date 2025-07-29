import 'package:sqflite/sqflite.dart';
import '../../../core/database/app_database.dart';
import 'sales_invoice_type_model.dart';

class SalesInvoiceTypeDao {
  Future<void> insertTypes(List<SalesInvoiceType> types) async {
    final db = await AppDatabase.instance.database;
    final batch = db.batch();
    for (final type in types) {
      batch.insert('sales_invoice_types', type.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<SalesInvoiceType>> getAllTypes() async {
    final db = await AppDatabase.instance.database;
    final result = await db.query('sales_invoice_types');
    return result.map((e) => SalesInvoiceType.fromMap(e)).toList();
  }

  Future<void> clearTypes() async {
    final db = await AppDatabase.instance.database;
    await db.delete('sales_invoice_types');
  }
}
