import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vos_supersales/core/theme/app_theme.dart';
import 'package:vos_supersales/features/auth/global_user.dart';
import 'package:vos_supersales/features/auth/global_salesman.dart';
import 'package:vos_supersales/features/transactions/invoice_dao.dart';
import 'package:vos_supersales/features/transactions/transactions_page.dart';
import 'package:vos_supersales/features/sales/invoice/sales_invoice_model.dart';
import 'package:vos_supersales/features/sales/invoice/invoice_detail_model.dart';
import 'quantity_selector_dialog.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> cart;
  final String customerCode;

  const CheckoutPage({
    super.key,
    required this.cart,
    required this.customerCode,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late List<Map<String, dynamic>> _cart;

  final List<Map<String, dynamic>> paymentMethods = [
    {"method_id": 1, "method_name": "Cash"},
    {"method_id": 2, "method_name": "Credit Card"},
    {"method_id": 3, "method_name": "Bank Transfer"},
    {"method_id": 4, "method_name": "Check"},
    {"method_id": 5, "method_name": "Online Payment"},
    {"method_id": 6, "method_name": "Wire Transfer"},
    {"method_id": 9, "method_name": "Online Banking"},
  ];

  int? _selectedMethodId;

  @override
  void initState() {
    super.initState();
    _cart = List.from(widget.cart);
  }

  double get totalAmount {
    return _cart.fold(0.0, (sum, item) {
      final price = (item['price'] ?? 0) as num;
      final qty = (item['quantity'] ?? 0) as num;
      return sum + price * qty;
    });
  }

  void _editQuantity(int index) async {
    final product = _cart[index];
    final newQty = await showDialog<int>(
      context: context,
      builder: (_) => QuantitySelectorDialog(
        productName: product['name'],
        initialQuantity: product['quantity'],
      ),
    );

    if (newQty != null && newQty > 0) {
      setState(() {
        _cart[index]['quantity'] = newQty;
      });
    }
  }

  void _removeItem(int index) {
    setState(() {
      _cart.removeAt(index);
    });
  }

  void _confirmSale() async {
    if (_selectedMethodId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method.')),
      );
      return;
    }

    final user = GlobalUser.getUser();
    final salesman = GlobalSalesman.getSalesman();

    if (user == null || salesman == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User or salesman not found.')),
      );
      return;
    }

    final now = DateTime.now();
    final orderId = 'ORD-${now.microsecondsSinceEpoch}';
    final invoiceNo = 'INV-${now.microsecondsSinceEpoch}';

    final invoiceDetails = _cart.map((item) {
      final price = (item['price'] ?? 0) as num;
      final quantity = (item['quantity'] ?? 0) as int;
      final total = price * quantity;

      return InvoiceDetail(
        detailId: 0,
        orderId: orderId,
        productId: item['productId'] ?? 0,
        productName: item['name'] ?? 'Unknown Product',
        unit: item['unitId'] ?? 0,
        unitPrice: price.toDouble(),
        quantity: quantity,
        discountAmount: 0,
        grossAmount: total.toDouble(),
        totalAmount: total.toDouble(),
        createdDate: now,
        modifiedDate: now,
        invoiceId: 0,
      );
    }).toList();

    final invoice = Invoice(
      invoiceId: 0,
      orderId: orderId,
      customerCode: widget.customerCode,
      invoiceNo: invoiceNo,
      salesmanId: salesman.id,
      invoiceDate: now.toIso8601String(),
      transactionStatus: 'Completed',
      paymentStatus: 'Unpaid',
      totalAmount: totalAmount,
      vatAmount: 0,
      grossAmount: totalAmount,
      discountAmount: 0,
      netAmount: totalAmount,
      isReceipt: true,
      isPosted: false,
      isDispatched: false,
      isSynced: false,
      invoiceDetails: invoiceDetails,
    );

    await InvoiceDao.insertInvoices([invoice], fromApi: false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invoice saved locally!')),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionsPage(currentUser: user),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _cart.isEmpty
                  ? const Center(child: Text('Your cart is empty.'))
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _cart.length,
                itemBuilder: (context, index) {
                  final item = _cart[index];
                  final name = item['name'] ?? '';
                  final quantity = item['quantity'] ?? 0;
                  final price = item['price'] ?? 0.0;
                  final total = quantity * price;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$quantity x ₱$price',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                                Text(
                                  '₱${total.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: AppColors.primary,
                            ),
                            onPressed: () => _editQuantity(index),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => _removeItem(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8,
                    color: Colors.black12,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<int>(
                    value: _selectedMethodId,
                    items: paymentMethods.map((method) {
                      return DropdownMenuItem<int>(
                        value: method['method_id'],
                        child: Text(method['method_name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedMethodId = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Payment Method',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '₱${totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _confirmSale,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text(
                      'Confirm Sale',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
