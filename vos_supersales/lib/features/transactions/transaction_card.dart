import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'widgets/status_badge.dart';

class TransactionCard extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final address = transaction['address'];
    final fullAddress =
        '${address['barangay']}, ${address['city']}, ${address['province']}';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Order ID + Receipt No + Receipt Type
            Row(
              children: [
                Expanded(child: Text('Order ID: ${transaction['orderId']}')),
                Expanded(child: Text('Receipt #: ${transaction['receiptNo']}')),
                Expanded(
                  child: Text('Receipt Type: ${transaction['receiptType']}'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Customer Name + Address
            Text(
              transaction['customerName'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(fullAddress, style: TextStyle(color: AppColors.grey)),
            const SizedBox(height: 8),
            // Total + Payment Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₱${transaction['total'].toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                StatusBadge(status: transaction['status'].toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
