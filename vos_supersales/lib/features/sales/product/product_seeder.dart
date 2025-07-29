import 'product_service.dart';

Future<void> seedProductsToDatabase() async {
  final products = await ProductService().fetchProductsFromApiAndSaveToDb();
  print('✅ Seeded ${products.length} products from API to SQLite');
}
