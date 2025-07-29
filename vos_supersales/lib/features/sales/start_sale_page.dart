import 'package:flutter/material.dart';
import 'package:vos_supersales/features/auth/global_salesman.dart';
import 'package:vos_supersales/features/auth/user_model.dart';
import 'package:vos_supersales/features/sales/salesman/salesman_model.dart';
import '../../core/theme/app_theme.dart';
import 'checkout_page.dart';
import 'product/product_search_dialog.dart';
import 'product/product_search_sku_dialog.dart';
import 'product/product_model.dart';
import 'customer/customer_model.dart';
import 'package:vos_supersales/features/sales/invoice/sales_invoice_type_model.dart';

class StartSalePage extends StatefulWidget {
  final UserModel currentUser;
  final Customer selectedCustomer;
  final SalesmanModel salesman;
  final String documentNo;
  final SalesInvoiceType invoiceType;

  const StartSalePage({
    super.key,
    required this.currentUser,
    required this.selectedCustomer,
    required this.salesman,
    required this.documentNo,
    required this.invoiceType,
  });

  @override
  State<StartSalePage> createState() => _StartSalePageState();
}

class _StartSalePageState extends State<StartSalePage> {
  final List<Map<String, dynamic>> _cart = [];
  final Map<String, double> _supplierDiscounts = {};

  void _openProductSearch({bool isReturn = false}) async {
    final selectedProducts = await showDialog<List<Map<String, dynamic>>>(
      context: context,
      builder: (_) => const ProductSearchDialog(),
    );

    if (selectedProducts != null && selectedProducts.isNotEmpty) {
      for (var product in selectedProducts) {
        final productMap = {
          'sku': product['sku'],
          'name': product['name'],
          'price': product['price'],
          'quantity': isReturn ? -product['quantity'] : product['quantity'],
          'supplier_id': product['supplier_id'],
          'base_price': product['base_price'],
        };

        _applyDiscountToProduct(productMap);

        setState(() {
          _cart.add(productMap);
        });
      }
    }
  }

  void _editDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Choose Action'),
        content: const Text('What do you want to do with this product?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _editQuantity(index);
            },
            child: const Text('Edit Quantity'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _editSkuWithSearch(index);
            },
            child: const Text('Edit SKU'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _removeItem(index);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _editQuantity(int index) async {
    final product = _cart[index];
    final controller = TextEditingController(
      text: product['quantity'].abs().toString(),
    );

    final newQty = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Quantity'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Enter quantity'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final qty = int.tryParse(controller.text.trim());
              if (qty != null && qty > 0) {
                Navigator.pop(context, qty);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );

    if (newQty != null) {
      setState(() {
        final isReturn = product['quantity'] < 0;
        _cart[index]['quantity'] = isReturn ? -newQty : newQty;
      });
    }
  }

  void _editSkuWithSearch(int index) async {
    final selectedProduct = await showDialog<Product>(
      context: context,
      builder: (_) => ProductSearchSkuDialog(
        onSelected: (product) => Navigator.pop(context, product),
      ),
    );

    if (selectedProduct != null) {
      setState(() {
        _cart[index]['sku'] = selectedProduct.barcode;
        _cart[index]['name'] = selectedProduct.productName;
        _cart[index]['price'] = selectedProduct.priceA;
        _cart[index]['supplier_id'] = selectedProduct.supplierId;
        _cart[index]['base_price'] = selectedProduct.priceA;
        _applyDiscountToProduct(_cart[index]);
      });
    }
  }

  void _removeItem(int index) {
    setState(() => _cart.removeAt(index));
  }

  double get totalAmount =>
      _cart.fold(0.0, (sum, item) => sum + item['price'] * item['quantity']);

  double get salesAmount => _cart
      .where((item) => item['quantity'] > 0)
      .fold(0.0, (sum, item) => sum + item['price'] * item['quantity']);

  double get returnAmount => _cart
      .where((item) => item['quantity'] < 0)
      .fold(0.0, (sum, item) => sum + item['price'] * -item['quantity']);

  void _showDiscountSheet() {
    final suppliers = _cart
        .map((item) => item['supplier_id'] ?? 'Unknown')
        .toSet()
        .toList();

    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                'Apply Discount by Supplier',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            ...suppliers.map((supplierId) {
              return ListTile(
                title: Text('Supplier: $supplierId'),
                subtitle: Text(
                  'Current Discount: ${_supplierDiscounts[supplierId]?.toStringAsFixed(1) ?? '0'}%',
                ),
                onTap: () {
                  Navigator.pop(context);
                  _promptDiscountForSupplier(supplierId);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _promptDiscountForSupplier(dynamic supplierId) {
    final controller = TextEditingController(
      text: _supplierDiscounts[supplierId]?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Discount for Supplier $supplierId'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            hintText: 'Enter % discount (e.g. 10)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(controller.text.trim());
              if (value != null && value >= 0) {
                setState(() {
                  _supplierDiscounts[supplierId] = value;
                  for (var item in _cart) {
                    if (item['supplier_id'] == supplierId) {
                      _applyDiscountToProduct(item);
                    }
                  }
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _applyDiscountToProduct(Map<String, dynamic> product) {
    final supplierId = product['supplier_id'];
    final basePrice = product['base_price'] ?? product['price'];
    product['base_price'] = basePrice;

    final discount = _supplierDiscounts[supplierId] ?? 0;
    final discounted = basePrice * (1 - discount / 100);
    product['price'] = double.parse(discounted.toStringAsFixed(2));
  }

  Widget _roundedMiniButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 48,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: EdgeInsets.zero,
        ),
        onPressed: onPressed,
        child: Icon(icon, size: 22, color: Colors.white),
      ),
    );
  }
@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.selectedCustomer.customerName,
                style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(
              '${widget.selectedCustomer.brgy}, ${widget.selectedCustomer.city}, ${widget.selectedCustomer.province}',
              style: const TextStyle(fontSize: 12),
            ),
            Text(widget.documentNo, style: const TextStyle(fontSize: 12)),
            Text('Type: ${widget.invoiceType.type}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showDiscountSheet,
            icon: const Icon(Icons.local_offer_outlined),
            tooltip: 'Discounts',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: Text(
                  '₱${totalAmount.toStringAsFixed(2)}',
                  style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: _cart.isEmpty
          ? const Center(child: Text('No products added yet.'))
          : Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Expanded(flex: 1, child: SizedBox()),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Product',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text('Price', style: TextStyle(fontSize: 12)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text('Qty', style: TextStyle(fontSize: 12)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text('Amount', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _cart.length,
                      itemBuilder: (_, index) {
                        final item = _cart[index];
                        final isReturn = item['quantity'] < 0;
                        final total = item['price'] * item['quantity'];

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: IconButton(
                                  icon: const Icon(Icons.edit, size: 18),
                                  onPressed: () => _editDeleteDialog(index),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  '${item['name']} ${isReturn ? "(RETURN)" : ""}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isReturn ? Colors.red : null,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '₱${item['price']}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${item['quantity']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isReturn ? Colors.red : null,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '₱${total.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isReturn ? Colors.red : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _roundedMiniButton(
                icon: Icons.remove,
                color: Colors.redAccent,
                onPressed: () => _openProductSearch(isReturn: true),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Returns: ₱${returnAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 1,
                      height: 20,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Sales: ₱${salesAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _roundedMiniButton(
                icon: Icons.add,
                color: AppColors.primary,
                onPressed: _openProductSearch,
              ),
            ],
          ),
        ),
      ),

// UPDATE this inside bottomSheet:
      bottomSheet: _cart.isNotEmpty
          ? Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CheckoutPage(
                      cart: _cart,
                      customerCode: widget.selectedCustomer.customerCode,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Confirm Sale'),
            ),
          ),
        ),
      )
          : null,
    );
  }
}