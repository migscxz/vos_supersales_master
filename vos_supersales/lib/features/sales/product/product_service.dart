import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:vos_supersales/core/database/app_database.dart';
import 'product_model.dart';
import 'package:vos_supersales/core/constants/api_constants.dart';

class ProductService {
  /// ✅ Try to fetch products from API and save to local DB
  /// ❌ If API fails, fallback to local DB
  Future<List<Product>> fetchProductsFromApiAndSaveToDb() async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.products));


      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final List<Product> products = jsonList
            .map((json) => Product.fromJson(json))
            .toList();

        final db = await AppDatabase.instance.database;

        await db.execute('''
          CREATE TABLE IF NOT EXISTS products (
            productId INTEGER PRIMARY KEY,
            productName TEXT,
            barcode TEXT,
            shortDescription TEXT,
            unit TEXT,
            unitCount INTEGER,
            priceA REAL,
            priceB REAL,
            priceC REAL,
            priceD REAL,
            priceE REAL,
            brandName TEXT,
            categoryName TEXT,
            isActive INTEGER,
            isSynced INTEGER,
            syncedAt TEXT
          )
        ''');

        await db.delete('products');
        for (var product in products) {
          await db.insert('products', product.toMap());
        }

        return products;
      } else {
        throw Exception('Failed to fetch products: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      print('⚠️ SocketException: $e');
      print('🔁 Loading from local DB instead...');
      return await fetchProductsFromLocalDb();
    } catch (e) {
      print('❌ Unexpected error: $e');
      print('🔁 Loading from local DB instead...');
      return await fetchProductsFromLocalDb();
    }
  }

  /// ✅ Get from local SQLite
  Future<List<Product>> getProducts() async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query('products');
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  /// ✅ Alias
  Future<List<Product>> fetchProductsFromLocalDb() async {
    return await getProducts();
  }

  /// ✅ Seeding with fallback
  Future<void> seedProductsToDatabase() async {
    await fetchProductsFromApiAndSaveToDb();
  }
}
