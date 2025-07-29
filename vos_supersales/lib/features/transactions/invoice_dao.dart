import 'package:vos_supersales/core/database/app_database.dart';
import 'package:vos_supersales/features/sales/invoice/sales_invoice_model.dart';
import 'package:vos_supersales/features/sales/invoice/invoice_detail_model.dart';
import 'package:sqflite/sqflite.dart';

class InvoiceDao {
  static Future<void> insertInvoices(List<Invoice> invoices, {bool fromApi = true}) async {
    final db = await AppDatabase.instance.database;
    final batch = db.batch();

    print('🧾 Inserting ${invoices.length} invoices into SQLite');

    for (final invoice in invoices) {
      batch.insert('invoices', {
        'invoiceId': invoice.invoiceId,
        'orderId': invoice.orderId,
        'customerCode': invoice.customerCode,
        'invoiceNo': invoice.invoiceNo,
        'transactionStatus': invoice.transactionStatus,
        'paymentStatus': invoice.paymentStatus,
        'totalAmount': invoice.totalAmount,
        'invoiceDate': invoice.invoiceDate,
        'dispatchDate': invoice.dispatchDate,
        'dueDate': invoice.dueDate,
        'paymentTerms': invoice.paymentTerms,
        'salesType': invoice.salesType,
        'invoiceTypeId': invoice.invoiceTypeId,
        'invoiceType': invoice.invoiceType,
        'invoiceTypeShortcut': invoice.invoiceTypeShortcut,
        'priceType': invoice.priceType,
        'vatAmount': invoice.vatAmount,
        'grossAmount': invoice.grossAmount,
        'discountAmount': invoice.discountAmount,
        'netAmount': invoice.netAmount,
        'createdBy': invoice.createdBy,
        'createdDate': invoice.createdDate,
        'modifiedBy': invoice.modifiedBy,
        'modifiedDate': invoice.modifiedDate,
        'postedBy': invoice.postedBy,
        'postedDate': invoice.postedDate,
        'remarks': invoice.remarks,
        'isReceipt': invoice.isReceipt ? 1 : 0,
        'isPosted': invoice.isPosted ? 1 : 0,
        'isDispatched': invoice.isDispatched ? 1 : 0,
        'isRemitted': invoice.isRemitted == true ? 1 : 0,
        'salesmanId': invoice.salesmanId,
        'isSynced': fromApi ? 1 : 0,
        'syncedAt': fromApi ? DateTime.now().toIso8601String() : null,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      for (final detail in invoice.invoiceDetails) {
        batch.insert('invoice_details', {
          'detailId': detail.detailId,
          'orderId': detail.orderId,
          'productId': detail.productId,
          'productName': detail.productName,
          'unit': detail.unit,
          'unitPrice': detail.unitPrice,
          'quantity': detail.quantity,
          'discountAmount': detail.discountAmount,
          'grossAmount': detail.grossAmount,
          'totalAmount': detail.totalAmount,
          'createdDate': detail.createdDate?.toIso8601String(),
          'modifiedDate': detail.modifiedDate?.toIso8601String(),
          'invoiceId': detail.invoiceId,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }

    await batch.commit(noResult: true);
    print('✅ Invoices and their details inserted into SQLite');
  }

  static Future<List<Invoice>> getAllInvoices() async {
    final db = await AppDatabase.instance.database;
    final invoiceMaps = await db.query('invoices');
    return mapInvoices(invoiceMaps, db);
  }

  static Future<List<Invoice>> getInvoicesBySalesmanId(int salesmanId) async {
    final db = await AppDatabase.instance.database;
    final invoiceMaps = await db.query(
      'invoices',
      where: 'salesmanId = ? AND isSynced = 1',
      whereArgs: [salesmanId],
    );
    return mapInvoices(invoiceMaps, db);
  }

  static Future<List<Invoice>> mapInvoices(
      List<Map<String, dynamic>> invoiceMaps,
      Database db,
      ) async {
    List<Invoice> invoices = [];

    for (final invoiceMap in invoiceMaps) {
      final details = await db.query(
        'invoice_details',
        where: 'orderId = ?',
        whereArgs: [invoiceMap['orderId']],
      );

      final invoiceDetails = details.map((detailMap) {
        return InvoiceDetail(
          detailId: detailMap['detailId'] as int,
          orderId: detailMap['orderId']?.toString() ?? '',
          productId: detailMap['productId'] as int,
          productName: detailMap['productName']?.toString() ?? '',
          unit: detailMap['unit'] as int,
          unitPrice: (detailMap['unitPrice'] as num?)?.toDouble() ?? 0.0,
          quantity: detailMap['quantity'] as int,
          discountAmount: (detailMap['discountAmount'] as num?)?.toDouble() ?? 0.0,
          grossAmount: (detailMap['grossAmount'] as num?)?.toDouble() ?? 0.0,
          totalAmount: (detailMap['totalAmount'] as num?)?.toDouble() ?? 0.0,
          createdDate: DateTime.tryParse(detailMap['createdDate']?.toString() ?? '') ?? DateTime.now(),
          modifiedDate: DateTime.tryParse(detailMap['modifiedDate']?.toString() ?? '') ?? DateTime.now(),
          invoiceId: detailMap['invoiceId'] as int,
        );
      }).toList();

      invoices.add(
        Invoice(
          invoiceId: invoiceMap['invoiceId'] as int,
          orderId: invoiceMap['orderId']?.toString() ?? '',
          customerCode: invoiceMap['customerCode']?.toString() ?? '',
          invoiceNo: invoiceMap['invoiceNo']?.toString() ?? '',
          transactionStatus: invoiceMap['transactionStatus']?.toString() ?? '',
          paymentStatus: invoiceMap['paymentStatus']?.toString() ?? '',
          totalAmount: (invoiceMap['totalAmount'] as num?)?.toDouble() ?? 0.0,
          invoiceDate: invoiceMap['invoiceDate']?.toString() ?? '',
          dispatchDate: invoiceMap['dispatchDate']?.toString(),
          dueDate: invoiceMap['dueDate']?.toString(),
          paymentTerms: invoiceMap['paymentTerms'] as int?,
          salesType: invoiceMap['salesType'] as int?,
          invoiceTypeId: invoiceMap['invoiceTypeId'] as int?,
          invoiceType: invoiceMap['invoiceType']?.toString(),
          invoiceTypeShortcut: invoiceMap['invoiceTypeShortcut']?.toString(),
          priceType: invoiceMap['priceType']?.toString(),
          vatAmount: (invoiceMap['vatAmount'] as num?)?.toDouble() ?? 0.0,
          grossAmount: (invoiceMap['grossAmount'] as num?)?.toDouble() ?? 0.0,
          discountAmount: (invoiceMap['discountAmount'] as num?)?.toDouble() ?? 0.0,
          netAmount: (invoiceMap['netAmount'] as num?)?.toDouble() ?? 0.0,
          createdBy: invoiceMap['createdBy'] as int?,
          createdDate: invoiceMap['createdDate']?.toString(),
          modifiedBy: invoiceMap['modifiedBy'] as int?,
          modifiedDate: invoiceMap['modifiedDate']?.toString(),
          postedBy: invoiceMap['postedBy'] as int?,
          postedDate: invoiceMap['postedDate']?.toString(),
          remarks: invoiceMap['remarks']?.toString(),
          isReceipt: invoiceMap['isReceipt'] == 1,
          isPosted: invoiceMap['isPosted'] == 1,
          isDispatched: invoiceMap['isDispatched'] == 1,
          isRemitted: invoiceMap['isRemitted'] == 1,
          salesmanId: invoiceMap['salesmanId'] as int,
          isSynced: (invoiceMap['isSynced'] ?? 0) == 1,
          syncedAt: invoiceMap['syncedAt'] != null
              ? DateTime.tryParse(invoiceMap['syncedAt'].toString())
              : null,
          invoiceDetails: invoiceDetails,
        ),
      );
    }

    print('📦 Loaded ${invoices.length} invoices from SQLite');
    return invoices;
  }

  /// ✅ New: Mark an invoice as synced
  static Future<void> markInvoiceAsSynced(int invoiceId) async {
    final db = await AppDatabase.instance.database;
    await db.update(
      'invoices',
      {
        'isSynced': 1,
        'syncedAt': DateTime.now().toIso8601String(),
      },
      where: 'invoiceId = ?',
      whereArgs: [invoiceId],
    );
    print('🔁 Invoice $invoiceId marked as synced');
  }
}
