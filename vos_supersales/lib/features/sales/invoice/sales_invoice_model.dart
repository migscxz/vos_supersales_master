import 'invoice_detail_model.dart';

class Invoice {
  final int invoiceId;
  final String orderId;
  final String customerCode;
  final String invoiceNo;
  final int salesmanId;
  final String invoiceDate;
  final String? dispatchDate;
  final String? dueDate;
  final int? paymentTerms;
  final String transactionStatus;
  final String paymentStatus;
  final double totalAmount;
  final int? salesType;
  final int? invoiceTypeId;
  final String? invoiceType;
  final String? invoiceTypeShortcut;
  final String? priceType;
  final double vatAmount;
  final double grossAmount;
  final double discountAmount;
  final double netAmount;
  final int? createdBy;
  final String? createdDate;
  final int? modifiedBy;
  final String? modifiedDate;
  final int? postedBy;
  final String? postedDate;
  final String? remarks;
  final bool isReceipt;
  final bool isPosted;
  final bool isDispatched;
  final bool? isRemitted;
  final bool isSynced;
  final DateTime? syncedAt;
  final List<InvoiceDetail> invoiceDetails;

  Invoice({
    required this.invoiceId,
    required this.orderId,
    required this.customerCode,
    required this.invoiceNo,
    required this.salesmanId,
    required this.invoiceDate,
    this.dispatchDate,
    this.dueDate,
    this.paymentTerms,
    required this.transactionStatus,
    required this.paymentStatus,
    required this.totalAmount,
    this.salesType,
    this.invoiceTypeId,
    this.invoiceType,
    this.invoiceTypeShortcut,
    this.priceType,
    required this.vatAmount,
    required this.grossAmount,
    required this.discountAmount,
    required this.netAmount,
    this.createdBy,
    this.createdDate,
    this.modifiedBy,
    this.modifiedDate,
    this.postedBy,
    this.postedDate,
    this.remarks,
    required this.isReceipt,
    required this.isPosted,
    required this.isDispatched,
    this.isRemitted,
    required this.isSynced,
    this.syncedAt,
    required this.invoiceDetails,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      invoiceId: json['invoiceId'],
      orderId: json['orderId'],
      customerCode: json['customerCode'],
      invoiceNo: json['invoiceNo'],
      salesmanId: json['salesmanId'],
      invoiceDate: json['invoiceDate'].toString(),
      dispatchDate: json['dispatchDate']?.toString(),
      dueDate: json['dueDate']?.toString(),
      paymentTerms: json['paymentTerms'],
      transactionStatus: json['transactionStatus'],
      paymentStatus: json['paymentStatus'],
      totalAmount: (json['totalAmount'] as num).toDouble(),
      salesType: json['salesType'],
      invoiceTypeId: json['invoiceTypeId'],
      invoiceType: json['invoiceType']?.toString(),
      invoiceTypeShortcut: json['invoiceTypeShortcut']?.toString(),
      priceType: json['priceType']?.toString(),
      vatAmount: (json['vatAmount'] as num).toDouble(),
      grossAmount: (json['grossAmount'] as num).toDouble(),
      discountAmount: (json['discountAmount'] as num).toDouble(),
      netAmount: (json['netAmount'] as num).toDouble(),
      createdBy: json['createdBy'],
      createdDate: json['createdDate']?.toString(),
      modifiedBy: json['modifiedBy'],
      modifiedDate: json['modifiedDate']?.toString(),
      postedBy: json['postedBy'],
      postedDate: json['postedDate']?.toString(),
      remarks: json['remarks']?.toString(),
      isReceipt: json['isReceipt'] == true,
      isPosted: json['isPosted'] == true,
      isDispatched: json['isDispatched'] == true,
      isRemitted: json['isRemitted'] == true,
      isSynced: true,
      syncedAt: DateTime.now(),
      invoiceDetails: (json['invoiceDetails'] as List<dynamic>)
          .map((detail) => InvoiceDetail.fromJson(detail))
          .toList(),
    );
  }
}
