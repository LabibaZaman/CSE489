import 'package:flutter/material.dart';
import '../../models/patient_model.dart';

class PatientDetailScreen extends StatelessWidget {
  final PatientModel patient;
  const PatientDetailScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(patient.name),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue,
                    child: Text(
                      patient.name[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 48,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildInfoRow(Icons.person, 'Name', patient.name),
                const Divider(),
                _buildInfoRow(Icons.calendar_today, 'Age', '${patient.age} years'),
                const Divider(),
                _buildInfoRow(Icons.wc, 'Gender', patient.gender),
                const Divider(),
                _buildInfoRow(Icons.phone, 'Contact', patient.contact),
                const Divider(),
                _buildInfoRow(Icons.location_on, 'Address', patient.address),
                const Divider(),
                _buildInfoRow(Icons.bloodtype, 'Blood Group', patient.bloodGroup),
                const Divider(),
                _buildInfoRow(Icons.history, 'Medical History',
                    patient.medicalHistory.isEmpty ? 'None' : patient.medicalHistory),
                const Divider(),
                _buildInfoRow(Icons.calendar_today, 'Registered On',
                    '${patient.createdAt.day}/${patient.createdAt.month}/${patient.createdAt.year}'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Colors.blue),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}