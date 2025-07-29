import 'package:flutter/material.dart';
import '../product/add_product_page.dart';

class SelectSupplierPage extends StatelessWidget {
  final List<String> suppliers;
  final Function(Map<String, dynamic>) onProductAdded;

  const SelectSupplierPage({
    super.key,
    required this.suppliers,
    required this.onProductAdded,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Supplier'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: suppliers.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (_, index) {
          final supplier = suppliers[index];
          return ListTile(
            title: Text(supplier),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddProductPage(
                    supplier: supplier,
                    onProductAdded: onProductAdded,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
