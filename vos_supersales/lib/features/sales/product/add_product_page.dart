import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'product_list_tile.dart';

class AddProductPage extends StatefulWidget {
  final String supplier;
  final Function(Map<String, dynamic>) onProductAdded;

  const AddProductPage({
    super.key,
    required this.supplier,
    required this.onProductAdded,
  });

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final List<Map<String, dynamic>> allProducts = [
    {'name': 'Coke', 'supplier': 'Supplier A', 'price': 20},
    {'name': 'Pepsi', 'supplier': 'Supplier A', 'price': 18},
    {'name': 'Chips', 'supplier': 'Supplier B', 'price': 15},
    {'name': 'Cookies', 'supplier': 'Supplier B', 'price': 25},
  ];

  final Map<String, int> _quantities = {};
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterProducts);
    _filterProducts();
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    filteredProducts = allProducts
        .where(
          (p) =>
              p['supplier'] == widget.supplier &&
              p['name'].toLowerCase().contains(query),
        )
        .toList();
    setState(() {});
  }

  void _incrementQuantity(String name) {
    setState(() {
      _quantities[name] = (_quantities[name] ?? 0) + 1;
    });
  }

  void _decrementQuantity(String name) {
    if ((_quantities[name] ?? 0) > 0) {
      setState(() {
        _quantities[name] = _quantities[name]! - 1;
      });
    }
  }

  void _submitAllProducts() {
    for (var product in filteredProducts) {
      final qty = _quantities[product['name']] ?? 0;
      if (qty > 0) {
        final item = {
          'name': product['name'],
          'price': product['price'],
          'quantity': qty,
        };
        widget.onProductAdded(item);
      }
    }
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product - ${widget.supplier}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredProducts.isEmpty
                ? const Center(child: Text('No products found.'))
                : ListView.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (_, index) {
                      final product = filteredProducts[index];
                      final qty = _quantities[product['name']] ?? 0;

                      return ProductListTile(
                        product: product,
                        quantity: qty,
                        onIncrement: () => _incrementQuantity(product['name']),
                        onDecrement: () => _decrementQuantity(product['name']),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _submitAllProducts,
        icon: const Icon(Icons.add),
        label: const Text('Add Products'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
