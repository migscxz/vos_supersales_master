import 'dart:convert';
import 'package:http/http.dart' as http;
import 'sales_invoice_type_model.dart';
import 'sales_invoice_type_dao.dart';
import '../../../core/constants/api_constants.dart';

class SalesInvoiceTypeService {
  final _dao = SalesInvoiceTypeDao();

  Future<List<SalesInvoiceType>> fetchInvoiceTypesFromApi() async {
    final response = await http.get(Uri.parse(ApiConstants.salesInvoiceTypes));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final types = data.map((json) => SalesInvoiceType.fromJson(json)).toList();
      await _dao.clearTypes(); // optional
      await _dao.insertTypes(types);
      return types;
    } else {
      throw Exception('Failed to fetch invoice types');
    }
  }

  Future<List<SalesInvoiceType>> getInvoiceTypesOffline() async {
    return await _dao.getAllTypes();
  }
}
