import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class SalesEntryPage extends StatefulWidget {
  const SalesEntryPage({super.key});

  @override
  State<SalesEntryPage> createState() => _SalesEntryPageState();
}

class _SalesEntryPageState extends State<SalesEntryPage> {
  final TextEditingController quantityController = TextEditingController();
  String? selectedProduct;
  final List<Map<String, dynamic>> invoiceItems = [];

  final List<Map<String, dynamic>> mockProducts = [
    {'id': 1, 'name': 'Product A', 'price': 100},
    {'id': 2, 'name': 'Product B', 'price': 150},
    {'id': 3, 'name': 'Product C', 'price': 200},
  ];

  void addItem() {
    final qty = int.tryParse(quantityController.text);
    if (selectedProduct != null && qty != null && qty > 0) {
      final product = mockProducts.firstWhere(
        (p) => p['name'] == selectedProduct,
      );
      setState(() {
        invoiceItems.add({
          'name': product['name'],
          'quantity': qty,
          'price': product['price'],
        });
        quantityController.clear();
        selectedProduct = null;
      });
    }
  }

  double get totalAmount {
    return invoiceItems.fold<double>(
      0,
      (sum, item) => sum + (item['quantity'] * item['price']),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Sale'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Select Product'),
              value: selectedProduct,
              items: mockProducts
                  .map(
                    (p) => DropdownMenuItem<String>(
                      value: p['name'] as String,
                      child: Text(p['name']),
                    ),
                  )
                  .toList(),
              onChanged: (val) => setState(() => selectedProduct = val),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: addItem,
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: invoiceItems.length,
                itemBuilder: (context, index) {
                  final item = invoiceItems[index];
                  return ListTile(
                    title: Text(item['name']),
                    subtitle: Text(
                      'Qty: ${item['quantity']} x ₱${item['price']}',
                    ),
                    trailing: Text(
                      '₱${item['quantity'] * item['price']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total:'),
                Text(
                  '₱${totalAmount.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Submit logic will go here
                },
                icon: const Icon(Icons.check),
                label: const Text('Submit Sale'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
