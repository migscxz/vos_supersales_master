class Product {
  final int productId;
  final String productName;
  final String? barcode;
  final String? shortDescription;
  final String unit;
  final int unitId;
  final int unitCount;
  final double priceA;
  final double priceB;
  final double priceC;
  final double priceD;
  final double priceE;
  final String? brandName;
  final String? categoryName;
  final int supplierId;
  final bool isActive;
  final bool isSynced;
  final String? syncedAt;

  Product({
    required this.productId,
    required this.productName,
    this.barcode,
    this.shortDescription,
    required this.unit,
    required this.unitId,
    required this.unitCount,
    required this.priceA,
    required this.priceB,
    required this.priceC,
    required this.priceD,
    required this.priceE,
    this.brandName,
    this.categoryName,
    required this.supplierId,
    required this.isActive,
    required this.isSynced,
    this.syncedAt,
  });

  static double _toDouble(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _mapUnitToId(String? unitName) {
    final unitMap = {
      'Pieces': 1,
      'Box': 2,
      'Pack': 3,
      'Kg': 4,
      'Bottle': 5,
      'Can': 6,
    };
    return unitMap[unitName?.trim()] ?? 0;
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      productId: map['productId'] ?? 0,
      productName: map['productName'] ?? '',
      barcode: map['barcode'],
      shortDescription: map['shortDescription'],
      unit: map['unit'] ?? '',
      unitId: map['unitId'] ?? _mapUnitToId(map['unit']),
      unitCount: map['unitCount'] ?? 1,
      priceA: _toDouble(map['priceA']),
      priceB: _toDouble(map['priceB']),
      priceC: _toDouble(map['priceC']),
      priceD: _toDouble(map['priceD']),
      priceE: _toDouble(map['priceE']),
      brandName: map['brandName'],
      categoryName: map['categoryName'],
      supplierId: map['supplierId'] ?? 0,
      isActive: (map['isActive'] ?? 1) == 1,
      isSynced: (map['isSynced'] ?? 0) == 1,
      syncedAt: map['syncedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'barcode': barcode,
      'shortDescription': shortDescription,
      'unit': unit,
      'unitId': unitId,
      'unitCount': unitCount,
      'priceA': priceA,
      'priceB': priceB,
      'priceC': priceC,
      'priceD': priceD,
      'priceE': priceE,
      'brandName': brandName,
      'categoryName': categoryName,
      'supplierId': supplierId,
      'isActive': isActive ? 1 : 0,
      'isSynced': isSynced ? 1 : 0,
      'syncedAt': syncedAt,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['productId'] ?? 0,
      productName: json['productName'] ?? '',
      barcode: json['barcode'],
      shortDescription: json['shortDescription'],
      unit: json['unit'] ?? '',
      unitId: json['unitId'] ?? _mapUnitToId(json['unit']),
      unitCount: json['unitCount'] ?? 1,
      priceA: _toDouble(json['priceA']),
      priceB: _toDouble(json['priceB']),
      priceC: _toDouble(json['priceC']),
      priceD: _toDouble(json['priceD']),
      priceE: _toDouble(json['priceE']),
      brandName: json['brandName'],
      categoryName: json['categoryName'],
      supplierId: json['supplierId'] ?? 0,
      isActive: json['isActive'] == true || json['isActive'] == 1,
      isSynced: json['isSynced'] == true || json['isSynced'] == 1,
      syncedAt: json['syncedAt'],
    );
  }

  Map<String, dynamic> toJson() => toMap();
}
