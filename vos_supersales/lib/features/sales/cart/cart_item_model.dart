import 'package:vos_supersales/features/sales/returns/sales_return_type_model.dart';
class CartItem {
  final int productId;
  final String name;
  final String sku;
  final double price;
  final String unit;
  int quantity;
  final SalesReturnType? returnType;

  CartItem({
    required this.productId,
    required this.name,
    required this.sku,
    required this.price,
    required this.unit,
    required this.quantity,
    this.returnType,
  });

  double get total => price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'sku': sku,
      'price': price,
      'unit': unit,
      'quantity': quantity,
      'returnType': returnType != null
          ? {
        'typeId': returnType!.typeId,
        'typeName': returnType!.typeName,
        'description': returnType!.description,
      }
          : null,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'],
      name: json['name'],
      sku: json['sku'],
      price: (json['price'] as num).toDouble(),
      unit: json['unit'],
      quantity: json['quantity'],
      returnType: json['returnType'] != null
          ? SalesReturnType.fromJson(json['returnType'])
          : null,
    );
  }
}