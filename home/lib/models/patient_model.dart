class PatientModel {
  String id;
  String name;
  int age;
  String gender;
  String contact;
  String address;
  String bloodGroup;
  String medicalHistory;
  DateTime createdAt;

  PatientModel({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.contact,
    required this.address,
    required this.bloodGroup,
    required this.medicalHistory,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'contact': contact,
      'address': address,
      'bloodGroup': bloodGroup,
      'medicalHistory': medicalHistory,
      'createdAt': createdAt,
    };
  }

  factory PatientModel.fromMap(Map<String, dynamic> map) {
    return PatientModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      gender: map['gender'] ?? '',
      contact: map['contact'] ?? '',
      address: map['address'] ?? '',
      bloodGroup: map['bloodGroup'] ?? '',
      medicalHistory: map['medicalHistory'] ?? '',
      createdAt: (map['createdAt'] as dynamic).toDate(),
    );
  }
}