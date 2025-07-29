class UserModel {
  final int userId;
  final String email;
  final String password;
  final String fullName;
  final String departmentName;
  final String position;
  final bool isActive;

  UserModel({
    required this.userId,
    required this.email,
    required this.password,
    required this.fullName,
    required this.departmentName,
    required this.position,
    required this.isActive,
  });

  /// ✅ From API JSON
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    userId: json['userId'] ?? 0,
    email: json['email'] ?? '',
    password: json['password'] ?? '',
    fullName: json['fullName'] ?? '',
    departmentName: json['departmentName'] ?? '',
    position: json['position'] ?? '',
    isActive: json['isActive'] == true || json['isActive'] == 1,
  );

  /// ✅ To JSON (optional for sending to API)
  Map<String, dynamic> toJson() => {
    'userId': userId,
    'email': email,
    'password': password,
    'fullName': fullName,
    'departmentName': departmentName,
    'position': position,
    'isActive': isActive,
  };

  /// ✅ For saving to SQLite
  Map<String, dynamic> toMap() => {
    'user_id': userId,
    'email': email,
    'password': password,
    'full_name': fullName,
    'department_name': departmentName,
    'position': position,
    'is_active': isActive ? 1 : 0,
  };

  /// ✅ From SQLite query row
  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    userId: map['user_id'],
    email: map['email'],
    password: map['password'],
    fullName: map['full_name'],
    departmentName: map['department_name'],
    position: map['position'],
    isActive: map['is_active'] == 1,
  );

  String get userName => fullName;

  // Optional placeholders – remove if unused
  get salesmanId => null;
  get salesmanName => null;
  get operationName => null;
  get id => null;
}
