class SalesReturnType {
  final int typeId;
  final String typeName;
  final String description;

  SalesReturnType({
    required this.typeId,
    required this.typeName,
    required this.description,
  });

  factory SalesReturnType.fromJson(Map<String, dynamic> json) {
    return SalesReturnType(
      typeId: json['typeId'],
      typeName: json['typeName'],
      description: json['description'],
    );
  }
}
