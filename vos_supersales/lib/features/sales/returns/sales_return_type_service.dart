import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import 'sales_return_type_model.dart';

class SalesReturnTypeService {
  final String apiUrl = ApiConstants.salesReturnTypes;

  Future<List<SalesReturnType>> fetchReturnTypes() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => SalesReturnType.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load return types');
    }
  }
}
