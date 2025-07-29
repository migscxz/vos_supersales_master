import 'package:vos_supersales/features/sales/product/product_service.dart';
import 'package:vos_supersales/core/database/app_database.dart';

Future<void> seedProductsToDatabase() async {
  final db = await AppDatabase.instance.database;
  final products = await ProductService().fetchProductsFromLocalDb();

  // Make sure products table exists
  await db.execute('''
    CREATE TABLE IF NOT EXISTS products (
      productId INTEGER PRIMARY KEY,
      productName TEXT,
      barcode TEXT,
      unit TEXT,
      unitCount INTEGER,
      priceA REAL,
      priceB REAL,
      priceC REAL,
      priceD REAL,
      priceE REAL,
      brandName TEXT,
      categoryName TEXT,
      shortDescription TEXT,
      isActive INTEGER,
      isSynced INTEGER,
      syncedAt TEXT
    )
  ''');

  for (final product in products) {
    await db.insert('products', {
      'productId': product.productId,
      'productName': product.productName,
      'barcode': product.barcode,
      'unit': product.unit,
      'unitCount': product.unitCount,
      'priceA': product.priceA,
      'priceB': product.priceB,
      'priceC': product.priceC,
      'priceD': product.priceD,
      'priceE': product.priceE,
      'brandName': product.brandName,
      'categoryName': product.categoryName,
      'shortDescription': product.shortDescription,
      'isActive': product.isActive ? 1 : 0,
      'isSynced': 1,
      'syncedAt': DateTime.now().toIso8601String(),
    });
  }
}
