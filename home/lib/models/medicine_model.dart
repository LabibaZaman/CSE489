class MedicineModel {
  String id;
  String name;
  String category;
  int stock;
  double price;
  String expiryDate;
  String manufacturer;
  DateTime createdAt;

  MedicineModel({
    required this.id,
    required this.name,
    required this.category,
    required this.stock,
    required this.price,
    required this.expiryDate,
    required this.manufacturer,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'stock': stock,
      'price': price,
      'expiryDate': expiryDate,
      'manufacturer': manufacturer,
      'createdAt': createdAt,
    };
  }

  factory MedicineModel.fromMap(Map<String, dynamic> map) {
    return MedicineModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      stock: map['stock'] ?? 0,
      price: (map['price'] ?? 0).toDouble(),
      expiryDate: map['expiryDate'] ?? '',
      manufacturer: map['manufacturer'] ?? '',
      createdAt: (map['createdAt'] as dynamic).toDate(),
    );
  }
}