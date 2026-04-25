import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/patient_model.dart';
import '../models/appointment_model.dart';
import '../models/medicine_model.dart';
import '../models/invoice_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check if Firestore is available
  Future<bool> checkConnection() async {
    try {
      await _firestore.collection('users').limit(1).get();
      return true;
    } catch (e) {
      print('Firestore connection error: $e');
      return false;
    }
  }

  // Patient Operations
  Future<void> addPatient(PatientModel patient) async {
    try {
      await _firestore.collection('patients').doc(patient.id).set(patient.toMap());
    } catch (e) {
      print('Error adding patient: $e');
      rethrow;
    }
  }

  Future<List<PatientModel>> getPatients() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('patients')
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => PatientModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error getting patients: $e');
      return [];
    }
  }

  Future<void> updatePatient(PatientModel patient) async {
    try {
      await _firestore.collection('patients').doc(patient.id).update(patient.toMap());
    } catch (e) {
      print('Error updating patient: $e');
      rethrow;
    }
  }

  Future<void> deletePatient(String id) async {
    try {
      await _firestore.collection('patients').doc(id).delete();
    } catch (e) {
      print('Error deleting patient: $e');
      rethrow;
    }
  }

  // Appointment Operations
  Future<void> addAppointment(AppointmentModel appointment) async {
    try {
      await _firestore
          .collection('appointments')
          .doc(appointment.id)
          .set(appointment.toMap())
          .timeout(const Duration(seconds: 10)); // Add timeout
    } catch (e) {
      print('Error adding appointment: $e');
      rethrow;
    }
  }

  Future<List<AppointmentModel>> getAppointments() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('appointments')
          .orderBy('date', descending: true)
          .get();
      return snapshot.docs.map((doc) => AppointmentModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error getting appointments: $e');
      return [];
    }
  }

  Future<List<AppointmentModel>> getTodayAppointments() async {
    try {
      DateTime today = DateTime.now();
      DateTime startOfDay = DateTime(today.year, today.month, today.day);
      DateTime endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

      QuerySnapshot snapshot = await _firestore
          .collection('appointments')
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .where('date', isLessThanOrEqualTo: endOfDay)
          .get();

      return snapshot.docs.map((doc) => AppointmentModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error getting today appointments: $e');
      return [];
    }
  }

  Future<void> updateAppointmentStatus(String id, String status) async {
    try {
      await _firestore.collection('appointments').doc(id).update({'status': status});
    } catch (e) {
      print('Error updating appointment status: $e');
      rethrow;
    }
  }

  // Medicine Operations
  Future<void> addMedicine(MedicineModel medicine) async {
    try {
      await _firestore.collection('medicines').doc(medicine.id).set(medicine.toMap());
    } catch (e) {
      print('Error adding medicine: $e');
      rethrow;
    }
  }

  Future<List<MedicineModel>> getMedicines() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('medicines')
          .orderBy('name')
          .get();
      return snapshot.docs.map((doc) => MedicineModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error getting medicines: $e');
      return [];
    }
  }

  Future<void> updateMedicineStock(String id, int newStock) async {
    try {
      await _firestore.collection('medicines').doc(id).update({'stock': newStock});
    } catch (e) {
      print('Error updating medicine stock: $e');
      rethrow;
    }
  }

  Future<void> deleteMedicine(String id) async {
    try {
      await _firestore.collection('medicines').doc(id).delete();
    } catch (e) {
      print('Error deleting medicine: $e');
      rethrow;
    }
  }

  Future<List<MedicineModel>> getLowStockMedicines() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('medicines')
          .where('stock', isLessThan: 20)
          .get();
      return snapshot.docs.map((doc) => MedicineModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error getting low stock medicines: $e');
      return [];
    }
  }

  // Invoice Operations
  Future<void> addInvoice(InvoiceModel invoice) async {
    try {
      await _firestore.collection('invoices').doc(invoice.id).set(invoice.toMap());
    } catch (e) {
      print('Error adding invoice: $e');
      rethrow;
    }
  }

  Future<List<InvoiceModel>> getInvoices() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('invoices')
          .orderBy('date', descending: true)
          .get();
      return snapshot.docs.map((doc) => InvoiceModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error getting invoices: $e');
      return [];
    }
  }

  Future<void> updateInvoiceStatus(String id, String status) async {
    try {
      await _firestore.collection('invoices').doc(id).update({'status': status});
    } catch (e) {
      print('Error updating invoice status: $e');
      rethrow;
    }
  }

  // Dashboard Stats
  Future<int> getTotalPatients() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('patients').get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting total patients: $e');
      return 0;
    }
  }
// Get appointments by patient ID
  Future<List<AppointmentModel>> getAppointmentsByPatient(String patientId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('appointments')
          .where('patientId', isEqualTo: patientId)
          .orderBy('date', descending: true)
          .get();
      return snapshot.docs.map((doc) => AppointmentModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error getting appointments by patient: $e');
      return [];
    }
  }

// Get invoices by patient ID
  Future<List<InvoiceModel>> getInvoicesByPatient(String patientId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('invoices')
          .where('patientId', isEqualTo: patientId)
          .orderBy('date', descending: true)
          .get();
      return snapshot.docs.map((doc) => InvoiceModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error getting invoices by patient: $e');
      return [];
    }
  }
  Future<int> getTodayAppointmentsCount() async {
    try {
      DateTime today = DateTime.now();
      DateTime startOfDay = DateTime(today.year, today.month, today.day);
      DateTime endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

      QuerySnapshot snapshot = await _firestore
          .collection('appointments')
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .where('date', isLessThanOrEqualTo: endOfDay)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print('Error getting today appointments count: $e');
      return 0;
    }
  }

  Future<double> getTotalRevenue() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('invoices')
          .where('status', isEqualTo: 'paid')
          .get();

      double total = 0;
      for (var doc in snapshot.docs) {
        total += (doc.data() as Map<String, dynamic>)['amount'] ?? 0;
      }
      return total;
    } catch (e) {
      print('Error getting total revenue: $e');
      return 0;
    }
  }
}