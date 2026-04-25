import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/appointment_model.dart';
import '../models/patient_model.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  final DatabaseService _dbService = DatabaseService();
  final AuthService _authService = AuthService();

  List<AppointmentModel> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMyAppointments();
  }

  Future<void> _loadMyAppointments() async {
    setState(() => _isLoading = true);

    try {
      String? userId = _authService.getCurrentUserId();
      if (userId != null) {
        // Get patient record
        var patients = await _dbService.getPatients();
        var myPatient = patients.firstWhere(
              (p) => p.contact == _authService.getCurrentUser()?.email?.split('@').first,
          orElse: () => patients.first,
        );

        _appointments = await _dbService.getAppointmentsByPatient(myPatient.id);
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'scheduled': return Colors.orange;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _appointments.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No appointments found', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/book_appointment'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('Book Appointment'),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _appointments.length,
        itemBuilder: (context, index) {
          final appointment = _appointments[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(appointment.status).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          appointment.status.toUpperCase(),
                          style: TextStyle(
                            color: _getStatusColor(appointment.status),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        DateFormat('dd/MM/yyyy').format(appointment.date),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 20, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Dr. ${appointment.doctorName}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 20, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(appointment.time),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (appointment.symptoms.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Symptoms: ${appointment.symptoms}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  if (appointment.prescription.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Prescription: ${appointment.prescription}',
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}