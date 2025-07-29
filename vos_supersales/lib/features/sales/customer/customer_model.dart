class Customer {
  final int id;
  final String customerCode;
  final String customerName;
  final String storeName;
  final String storeSignage;
  final String customerImage;
  final String brgy;
  final String city;
  final String province;
  final String contactNumber;
  final String customerEmail;
  final String telNumber;
  final String? bankDetails;
  final String customerTin;
  final int? paymentTermId;
  final int storeTypeId;
  final String priceType;
  final int encoderId;
  final int? creditTypeId;
  final int companyCode;
  final bool isActive;
  final bool isVAT;
  final bool isEWT;
  final int? discountTypeId;
  final String otherDetails;
  final int? classificationId;
  final double? latitude;
  final double? longitude;
  final String dateEntered;
  final int isSynced;
  final String? syncedAt;

  Customer({
    required this.id,
    required this.customerCode,
    required this.customerName,
    required this.storeName,
    required this.storeSignage,
    required this.customerImage,
    required this.brgy,
    required this.city,
    required this.province,
    required this.contactNumber,
    required this.customerEmail,
    required this.telNumber,
    this.bankDetails,
    required this.customerTin,
    this.paymentTermId,
    required this.storeTypeId,
    required this.priceType,
    required this.encoderId,
    this.creditTypeId,
    required this.companyCode,
    required this.isActive,
    required this.isVAT,
    required this.isEWT,
    this.discountTypeId,
    required this.otherDetails,
    this.classificationId,
    this.latitude,
    this.longitude,
    required this.dateEntered,
    required this.isSynced,
    this.syncedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      customerCode: json['customerCode'] ?? '',
      customerName: json['customerName'] ?? '',
      storeName: json['storeName'] ?? '',
      storeSignage: json['storeSignage'] ?? '',
      customerImage: json['customerImage'] ?? '',
      brgy: json['brgy'] ?? '',
      city: json['city'] ?? '',
      province: json['province'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      customerEmail: json['customerEmail'] ?? '',
      telNumber: json['telNumber'] ?? '',
      bankDetails: json['bankDetails']?.toString(),
      customerTin: json['customerTin'] ?? '',
      paymentTermId: json['paymentTermId'],
      storeTypeId: json['storeTypeId'] ?? 0,
      priceType: json['priceType'] ?? '',
      encoderId: json['encoderId'] ?? 0,
      creditTypeId: json['creditTypeId'],
      companyCode: json['companyCode'] ?? 0,
      isActive: (json['isActive'] ?? 0) == 1,
      isVAT: (json['isVAT'] ?? 0) == 1,
      isEWT: (json['isEWT'] ?? 0) == 1,
      discountTypeId: json['discountTypeId'],
      otherDetails: json['otherDetails'] ?? '',
      classificationId: json['classificationId'],
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      dateEntered: json['dateEntered'] ?? '',
      isSynced: json['isSynced'] ?? 0,
      syncedAt: json['syncedAt'],
    );
  }

  /// For API payload
  Map<String, dynamic> toJson() {
    return {
      "customer_code": customerCode,
      "customer_name": customerName,
      "store_name": storeName,
      "store_signage": storeSignage,
      "customer_image": customerImage,
      "brgy": brgy,
      "city": city,
      "province": province,
      "contact_no": contactNumber,
      "customer_email": customerEmail,
      "tel_number": telNumber,
      "bank_details": bankDetails,
      "customer_tin": customerTin,
      "payment_term_id": paymentTermId,
      "store_type_id": storeTypeId,
      "price_type": priceType,
      "encoder_id": encoderId,
      "credit_type_id": creditTypeId,
      "company_code": companyCode,
      "is_active": isActive,
      "is_vat": isVAT,
      "is_ewt": isEWT,
      "discount_type_id": discountTypeId,
      "other_details": otherDetails,
      "classification_id": classificationId,
      "latitude": latitude,
      "longitude": longitude,
      "date_entered": dateEntered,
    };
  }

  /// For local SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerCode': customerCode,
      'customerName': customerName,
      'storeName': storeName,
      'storeSignage': storeSignage,
      'customerImage': customerImage,
      'brgy': brgy,
      'city': city,
      'province': province,
      'contactNumber': contactNumber,
      'customerEmail': customerEmail,
      'telNumber': telNumber,
      'bankDetails': bankDetails,
      'customerTin': customerTin,
      'paymentTermId': paymentTermId,
      'storeTypeId': storeTypeId,
      'priceType': priceType,
      'encoderId': encoderId,
      'creditTypeId': creditTypeId,
      'companyCode': companyCode,
      'isActive': isActive ? 1 : 0,
      'isVAT': isVAT ? 1 : 0,
      'isEWT': isEWT ? 1 : 0,
      'discountTypeId': discountTypeId,
      'otherDetails': otherDetails,
      'classificationId': classificationId,
      'latitude': latitude,
      'longitude': longitude,
      'dateEntered': dateEntered,
      'isSynced': isSynced,
      'syncedAt': syncedAt,
    };
  }
}
