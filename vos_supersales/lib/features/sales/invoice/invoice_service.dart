import 'dart:convert';
import 'package:http/http.dart' as http;
import 'sales_invoice_model.dart';
import 'package:vos_supersales/features/transactions/invoice_dao.dart';
import 'package:vos_supersales/core/constants/api_constants.dart';

class InvoiceService {
  Future<List<Invoice>> fetchInvoicesFromApi(int salesmanId) async {
    final url = Uri.parse('${ApiConstants.salesInvoices}/salesman/$salesmanId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final invoices = data.map((json) => Invoice.fromJson(json)).toList();

        await InvoiceDao.insertInvoices(invoices);
        return invoices;
      } else {
        throw Exception('Server returned error code ${response.statusCode}');
      }
    } catch (e) {
      print('⚠️ API failed, loading invoices from SQLite: $e');
      return await InvoiceDao.getInvoicesBySalesmanId(salesmanId);
    }
  }

  /// ✅ Static: Syncs all unsynced invoices to the API
  static Future<void> syncUnsyncedInvoices() async {
    final allInvoices = await InvoiceDao.getAllInvoices();
    final unsynced = allInvoices.where((invoice) => invoice.isSynced == false).toList();

    for (final invoice in unsynced) {
      try {
        final url = Uri.parse(ApiConstants.salesInvoices);
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(_invoiceToJson(invoice)),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          await InvoiceDao.markInvoiceAsSynced(invoice.invoiceId);
          print('✅ Synced invoice ${invoice.invoiceId}');
        } else {
          print('❌ Failed to sync invoice ${invoice.invoiceId}: ${response.body}');
        }
      } catch (e) {
        print('❌ Exception syncing invoice ${invoice.invoiceId}: $e');
      }
    }
  }

  /// ✅ Static helper for converting Invoice to JSON
  static Map<String, dynamic> _invoiceToJson(Invoice invoice) {
    final json = {
      "orderId": invoice.orderId,
      "customerCode": invoice.customerCode,
      "invoiceNo": invoice.invoiceNo,
      "salesmanId": invoice.salesmanId,
      "invoiceDate": invoice.invoiceDate,
      "dispatchDate": invoice.dispatchDate,
      "dueDate": invoice.dueDate,
      "paymentTerms": invoice.paymentTerms,
      "transactionStatus": invoice.transactionStatus,
      "paymentStatus": invoice.paymentStatus,
      "totalAmount": invoice.totalAmount,
      "salesType": invoice.salesType,
      "invoiceTypeId": invoice.invoiceTypeId,
      "invoiceType": invoice.invoiceType,
      "invoiceTypeShortcut": invoice.invoiceTypeShortcut,
      "priceType": invoice.priceType,
      "vatAmount": invoice.vatAmount,
      "grossAmount": invoice.grossAmount,
      "discountAmount": invoice.discountAmount,
      "netAmount": invoice.netAmount,
      "createdBy": invoice.createdBy,
      "createdDate": invoice.createdDate,
      "modifiedBy": invoice.modifiedBy,
      "modifiedDate": invoice.modifiedDate,
      "postedBy": invoice.postedBy,
      "postedDate": invoice.postedDate,
      "remarks": invoice.remarks,
      "isReceipt": invoice.isReceipt,
      "isPosted": invoice.isPosted,
      "isDispatched": invoice.isDispatched,
      "isRemitted": invoice.isRemitted,
      "isSynced": true,
      "syncedAt": DateTime.now().toIso8601String(),
      "invoiceDetails": invoice.invoiceDetails.map((detail) {
        return {
          "detailId": detail.detailId,
          "orderId": detail.orderId,
          "productId": detail.productId,
          "productName": detail.productName,
          "unit": detail.unit,
          "unitPrice": detail.unitPrice,
          "quantity": detail.quantity,
          "discountAmount": detail.discountAmount,
          "grossAmount": detail.grossAmount,
          "totalAmount": detail.totalAmount,
          "serialNo": detail.serialNo,
          "discountType": detail.discountType,
          "createdDate": detail.createdDate?.toIso8601String(),
          "modifiedDate": detail.modifiedDate?.toIso8601String(),
          "invoiceId": detail.invoiceId,
        };
      }).toList(),
    };

    // Only include invoiceId if it's not zero
    if (invoice.invoiceId != 0) {
      json["invoiceId"] = invoice.invoiceId;
    }

    return json;
  }}