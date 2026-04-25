class UserModel {
  String uid;
  String name;
  String email;
  String phone;
  String role;
  DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'createdAt': createdAt,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'patient',
      createdAt: (map['createdAt'] as dynamic).toDate(),
    );
  }
}

// Role definitions for manual database updates
class UserRoles {
  static const String doctor = 'doctor';
  static const String receptionist = 'receptionist';
  static const String pharmacist = 'pharmacist';
  static const String patient = 'patient';

  static List<String> get allRoles => [doctor, receptionist, pharmacist, patient];
  static List<String> get staffRoles => [doctor, receptionist, pharmacist];
}