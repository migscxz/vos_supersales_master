import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'product_model.dart';
import 'product_service.dart';

class ProductSearchDialog extends StatefulWidget {
  const ProductSearchDialog({super.key});

  @override
  State<ProductSearchDialog> createState() => _ProductSearchDialogState();
}

class _ProductSearchDialogState extends State<ProductSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  final Map<int, int> _quantities = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterProducts);
    _loadProductsFromDb(); // ✅ load from SQLite
  }

  Future<void> _loadProductsFromDb() async {
    try {
      final products = await ProductService().fetchProductsFromLocalDb();

      if (!mounted) return;

      setState(() {
        _allProducts = products;
        _filteredProducts = List.from(products);
        _isLoading = false;
      });

      debugPrint('Loaded ${products.length} products from local DB');
    } catch (e) {
      debugPrint('Error loading products from DB: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _allProducts.where((p) {
        return p.productName.toLowerCase().contains(query) ||
            (p.barcode?.toLowerCase().contains(query) ?? false) ||
            p.unit.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _increment(int id) {
    setState(() => _quantities[id] = (_quantities[id] ?? 0) + 1);
  }

  void _decrement(int id) {
    if ((_quantities[id] ?? 0) > 0) {
      setState(() => _quantities[id] = _quantities[id]! - 1);
    }
  }

  void _confirmSelection() {
    final selectedList = _filteredProducts
        .where((product) => (_quantities[product.productId] ?? 0) > 0)
        .map(
          (product) => {
        'productId': product.productId,         // ✅ needed in invoice
        'unitId': product.unitId,               // ✅ use ID, not name
        'sku': product.barcode,
        'name': product.productName,
        'price': product.priceB,
        'quantity': _quantities[product.productId]!,
        'supplier_id': product.supplierId,
        'base_price': product.priceB,
      },
    )
        .toList();

    Navigator.pop(context, selectedList);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        height: 520,
        child: Column(
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredProducts.isEmpty
                  ? const Center(child: Text('No products found.'))
                  : ListView.builder(
                      itemCount: _filteredProducts.length,
                      itemBuilder: (_, index) {
                        final product = _filteredProducts[index];
                        final id = product.productId;
                        final qty = _quantities[id] ?? 0;

                        return ListTile(
                          title: Text(
                            '${product.productName} (${product.unit})',
                          ),
                          subtitle: Text(
                            'SKU: ${product.barcode ?? "N/A"} • ₱${product.priceB.toStringAsFixed(2)} / ${product.unit}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => _decrement(id),
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                              Text(
                                '$qty',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                onPressed: () => _increment(id),
                                icon: const Icon(Icons.add_circle_outline),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _confirmSelection,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Add to Cart'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
