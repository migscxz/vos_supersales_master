class SalesmanModel {
  final int id;
  final int employeeId;
  final String? salesmanCode;
  final String? salesmanName;
  final String? truckPlate;
  final int divisionId;
  final int companyCode;
  final int supplierCode;
  final String priceType;
  final bool isActive;
  final bool isInventory;
  final bool canCollect;
  final int inventoryDay;
  final int encoderId;
  final int goodBranchId;
  final int badBranchId;
  final int operationId;
  final bool? isSynced;

  SalesmanModel({
    required this.id,
    required this.employeeId,
    required this.salesmanCode,
    required this.salesmanName,
    required this.truckPlate,
    required this.divisionId,
    required this.companyCode,
    required this.supplierCode,
    required this.priceType,
    required this.isActive,
    required this.isInventory,
    required this.canCollect,
    required this.inventoryDay,
    required this.encoderId,
    required this.goodBranchId,
    required this.badBranchId,
    required this.operationId,
    this.isSynced,
  });

  factory SalesmanModel.fromJson(Map<String, dynamic> json) {
    return SalesmanModel(
      id: json['id'],
      employeeId: json['employeeId'],
      salesmanCode: json['salesmanCode'] ?? '',
      salesmanName: json['salesmanName'] ?? '',
      truckPlate: json['truckPlate'] ?? '',
      divisionId: json['divisionId'],
      companyCode: json['companyCode'],
      supplierCode: json['supplierCode'],
      priceType: json['priceType'] ?? '',
      isActive: json['isActive'] ?? true,
      isInventory: json['isInventory'] ?? false,
      canCollect: json['canCollect'] ?? false,
      inventoryDay: json['inventoryDay'] ?? 0,
      encoderId: json['encoderId'] ?? 0,
      goodBranchId: json['goodBranchId'] ?? 0,
      badBranchId: json['badBranchId'] ?? 0,
      operationId: json['operationId'] ?? 0,
      isSynced: json['isSynced'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employee_id': employeeId,
      'salesmanCode': salesmanCode,
      'salesmanName': salesmanName,
      'truckPlate': truckPlate,
      'divisionId': divisionId,
      'companyCode': companyCode,
      'supplierCode': supplierCode,
      'priceType': priceType,
      'isActive': isActive ? 1 : 0,
      'isInventory': isInventory ? 1 : 0,
      'canCollect': canCollect ? 1 : 0,
      'inventoryDay': inventoryDay,
      'encoderId': encoderId,
      'goodBranchId': goodBranchId,
      'badBranchId': badBranchId,
      'operationId': operationId,
      'isSynced': isSynced == true ? 1 : 0,
    };
  }

  /// ✅ Convert map from SQLite back into SalesmanModel
  factory SalesmanModel.fromMap(Map<String, dynamic> map) {
    return SalesmanModel(
      id: map['id'],
      employeeId: map['employee_id'],
      salesmanCode: map['salesmanCode'],
      salesmanName: map['salesmanName'],
      truckPlate: map['truckPlate'],
      divisionId: map['divisionId'],
      companyCode: map['companyCode'],
      supplierCode: map['supplierCode'],
      priceType: map['priceType'],
      isActive: (map['isActive'] ?? 1) == 1,
      isInventory: (map['isInventory'] ?? 0) == 1,
      canCollect: (map['canCollect'] ?? 0) == 1,
      inventoryDay: map['inventoryDay'],
      encoderId: map['encoderId'],
      goodBranchId: map['goodBranchId'],
      badBranchId: map['badBranchId'],
      operationId: map['operationId'],
      isSynced: (map['isSynced'] ?? 0) == 1,
    );
  }
}
