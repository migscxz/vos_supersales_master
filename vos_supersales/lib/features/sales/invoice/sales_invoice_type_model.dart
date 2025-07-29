class SalesInvoiceType {
  final int id;
  final String type;
  final String shortcut;
  final int maxLength;

  SalesInvoiceType({
    required this.id,
    required this.type,
    required this.shortcut,
    required this.maxLength,
  });

  factory SalesInvoiceType.fromJson(Map<String, dynamic> json) {
    return SalesInvoiceType(
      id: json['id'],
      type: json['type'],
      shortcut: json['shortcut'],
      maxLength: json['maxLength'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'shortcut': shortcut,
      'maxLength': maxLength,
    };
  }

  factory SalesInvoiceType.fromMap(Map<String, dynamic> map) {
    return SalesInvoiceType(
      id: map['id'],
      type: map['type'],
      shortcut: map['shortcut'],
      maxLength: map['maxLength'],
    );
  }
}
