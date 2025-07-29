class InvoiceDetail {
  final int detailId;
  final String orderId;
  final int productId;
  final String productName;
  final int unit;
  final double unitPrice;
  final int quantity;
  final double discountAmount;
  final double grossAmount;
  final double totalAmount;
  final String? serialNo;
  final String? discountType;
  final DateTime? createdDate;
  final DateTime? modifiedDate;
  final int invoiceId;

  InvoiceDetail({
    required this.detailId,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.unit,
    required this.unitPrice,
    required this.quantity,
    required this.discountAmount,
    required this.grossAmount,
    required this.totalAmount,
    this.serialNo,
    this.discountType,
    this.createdDate,
    this.modifiedDate,
    required this.invoiceId,
  });

  factory InvoiceDetail.fromJson(Map<String, dynamic> json) {
    return InvoiceDetail(
      detailId: json['detailId'],
      orderId: json['orderId'],
      productId: json['productId'],
      productName: json['productName'],
      unit: json['unit'],
      unitPrice: (json['unitPrice'] as num).toDouble(),
      quantity: json['quantity'],
      discountAmount: (json['discountAmount'] as num).toDouble(),
      grossAmount: (json['grossAmount'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      serialNo: json['serialNo']?.toString(),
      discountType: json['discountType']?.toString(),
      createdDate: json['createdDate'] != null ? DateTime.tryParse(json['createdDate'].toString()) : null,
      modifiedDate: json['modifiedDate'] != null ? DateTime.tryParse(json['modifiedDate'].toString()) : null,
      invoiceId: json['invoiceId'],
    );
  }
}
