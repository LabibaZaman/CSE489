class AppointmentModel {
  String id;
  String patientId;
  String patientName;
  String doctorId;
  String doctorName;
  DateTime date;
  String time;
  String status; // scheduled, completed, cancelled
  String symptoms;
  String prescription;
  DateTime createdAt;

  AppointmentModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.date,
    required this.time,
    required this.status,
    required this.symptoms,
    required this.prescription,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'date': date,
      'time': time,
      'status': status,
      'symptoms': symptoms,
      'prescription': prescription,
      'createdAt': createdAt,
    };
  }

  factory AppointmentModel.fromMap(Map<String, dynamic> map) {
    return AppointmentModel(
      id: map['id'] ?? '',
      patientId: map['patientId'] ?? '',
      patientName: map['patientName'] ?? '',
      doctorId: map['doctorId'] ?? '',
      doctorName: map['doctorName'] ?? '',
      date: (map['date'] as dynamic).toDate(),
      time: map['time'] ?? '',
      status: map['status'] ?? 'scheduled',
      symptoms: map['symptoms'] ?? '',
      prescription: map['prescription'] ?? '',
      createdAt: (map['createdAt'] as dynamic).toDate(),
    );
  }
}