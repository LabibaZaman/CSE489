class InvoiceModel {
  String id;
  String patientId;
  String patientName;
  double amount;
  DateTime date;
  String status; // paid, pending
  List<Map<String, dynamic>> items;
  String paymentMethod;

  InvoiceModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.amount,
    required this.date,
    required this.status,
    required this.items,
    required this.paymentMethod,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'amount': amount,
      'date': date,
      'status': status,
      'items': items,
      'paymentMethod': paymentMethod,
    };
  }

  factory InvoiceModel.fromMap(Map<String, dynamic> map) {
    return InvoiceModel(
      id: map['id'] ?? '',
      patientId: map['patientId'] ?? '',
      patientName: map['patientName'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      date: (map['date'] as dynamic).toDate(),
      status: map['status'] ?? 'pending',
      items: List<Map<String, dynamic>>.from(map['items'] ?? []),
      paymentMethod: map['paymentMethod'] ?? '',
    );
  }
}