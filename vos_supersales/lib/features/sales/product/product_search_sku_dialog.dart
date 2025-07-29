import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../returns/sales_return_type_dialog.dart';
import '../returns/sales_return_type_model.dart';
import 'product_service.dart';

class ProductSearchSkuDialog extends StatefulWidget {
  const ProductSearchSkuDialog({super.key, required this.onSelected});

  final void Function(Map<String, dynamic> productWithReturnType) onSelected;

  @override
  State<ProductSearchSkuDialog> createState() => _ProductSearchSkuDialogState();
}

class _ProductSearchSkuDialogState extends State<ProductSearchSkuDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allProducts = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterProducts);
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await ProductService().fetchProductsFromLocalDb();
      if (!mounted) return;

      _allProducts = products.map((p) {
        return {
          'id': p.productId,
          'name': p.productName,
          'sku': p.barcode,
          'price': p.priceB,
          'unit': p.unit,
        };
      }).toList();

      setState(() {
        _filteredProducts = List.from(_allProducts);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      print('Error loading products: $e');
    }
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _allProducts.where((product) {
        final name = product['name'].toLowerCase();
        final sku = product['sku'].toLowerCase();
        return name.contains(query) || sku.contains(query);
      }).toList();
    });
  }

  Future<void> _selectProduct(Map<String, dynamic> product) async {
    final returnType = await showSalesReturnTypeDialog(context);
    if (returnType != null) {
      final productWithReturnType = {
        ...product,
        'returnType': {
          'typeId': returnType.typeId,
          'typeName': returnType.typeName,
          'description': returnType.description,
        }
      };
      widget.onSelected(productWithReturnType);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterProducts);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        height: 450,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: const Center(
                child: Text(
                  'Search Product by SKU',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search by name or SKU',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredProducts.isEmpty
                  ? const Center(child: Text('No products found.'))
                  : ListView.builder(
                itemCount: _filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = _filteredProducts[index];
                  return ListTile(
                    title: Text('${product['name']} (${product['unit']})'),
                    subtitle: Text('SKU: ${product['sku']}'),
                    trailing: Text('₱${product['price']} / ${product['unit']}'),
                    onTap: () => _selectProduct(product),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
