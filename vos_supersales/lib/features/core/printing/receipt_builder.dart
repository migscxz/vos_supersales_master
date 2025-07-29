// receipt_builder.dart
class ReceiptBuilder {
  static List<String> buildReceipt({
    required List<Map<String, dynamic>> cart,
    required String customerName,
    required String customerAddress,
    required String date,
    required double total,
    required String documentNumber, // Still needed to pass to printer
  }) {
    List<String> lines = [];

    lines.add('         $customerName');
    lines.add('           $date');
    lines.add('');
    lines.add('Customer: $customerName');
    lines.add('Address:  $customerAddress');
    lines.add('');
    lines.add('Item        Qty   Price');
    lines.add('------------------------');

    // ignore: unused_local_variable
    double finalTotal = 0.0;

    for (var item in cart) {
      String name = item['name'] ?? '';
      int qty = item['quantity'];
      double price = item['price'];
      double discount = item['discount'] ?? 0.0;

      double discountedPrice = price;
      if (discount > 0) {
        discountedPrice = price - (price * (discount / 100));
      }

      double lineTotal = discountedPrice * qty;
      finalTotal += lineTotal;

      lines.add(
        '${name.padRight(10).substring(0, 10)} ${qty.toString().padLeft(3)}  ₱${discountedPrice.toStringAsFixed(2)}',
      );

      if (discount > 0) {
        lines.add('  -${discount.toStringAsFixed(0)}% off');
      }
    }

    lines.add('------------------------');
    lines.add('Total:         ₱${total.toStringAsFixed(2)}');
    lines.add('');
    lines.add('Thank you!');

    return lines;
  }
}
