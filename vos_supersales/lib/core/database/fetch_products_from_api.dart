import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vos_supersales/core/constants/api_constants.dart';

Future<List<Map<String, dynamic>>> fetchProductsFromApi() async {
  try {
    final response = await http.get(Uri.parse(ApiConstants.products));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      } else if (data is Map && data.containsKey('products')) {
        return List<Map<String, dynamic>>.from(data['products']);
      } else {
        throw Exception('Invalid JSON structure');
      }
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Error fetching products: $e');
    return [];
  }
}
