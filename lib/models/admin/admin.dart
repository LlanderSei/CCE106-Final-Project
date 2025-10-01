// lib/models/admin/admin.dart
class Admin {
  final String id;
  final String fullName;
  final String email;
  final String passwordHash;

  Admin({
    required this.id,
    required this.fullName,
    required this.email,
    required this.passwordHash,
  });

  // Factory constructor to create from a map (e.g., from database)
  factory Admin.fromMap(Map<String, dynamic> map) {
    return Admin(
      id: map['id'],
      fullName: map['full_name'],
      email: map['email'],
      passwordHash: map['password_hash'],
    );
  }

  // Convert to map for storage (e.g., database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'password_hash': passwordHash,
    };
  }
}
