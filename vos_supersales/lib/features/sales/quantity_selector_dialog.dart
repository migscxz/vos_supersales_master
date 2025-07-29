import 'package:flutter/material.dart';

class QuantitySelectorDialog extends StatefulWidget {
  final String productName;
  final int initialQuantity;

  const QuantitySelectorDialog({
    super.key,
    required this.productName,
    this.initialQuantity = 1,
  });

  @override
  State<QuantitySelectorDialog> createState() => _QuantitySelectorDialogState();
}

class _QuantitySelectorDialogState extends State<QuantitySelectorDialog> {
  late TextEditingController quantityController;

  @override
  void initState() {
    super.initState();
    quantityController = TextEditingController(
      text: widget.initialQuantity.toString(),
    );
  }

  @override
  void dispose() {
    quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Enter Quantity for ${widget.productName}'),
      content: TextField(
        controller: quantityController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          hintText: 'Quantity',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final qty = int.tryParse(quantityController.text);
            if (qty != null && qty > 0) {
              Navigator.pop(context, qty);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a valid quantity')),
              );
            }
          },
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
