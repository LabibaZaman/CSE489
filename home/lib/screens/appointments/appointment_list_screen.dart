import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/database_service.dart';
import '../../models/appointment_model.dart';
import 'book_appointment_screen.dart';

class AppointmentListScreen extends StatefulWidget {
  const AppointmentListScreen({super.key});

  @override
  State<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  final DatabaseService _dbService = DatabaseService();
  List<AppointmentModel> _appointments = [];
  List<AppointmentModel> _filteredAppointments = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'scheduled', 'completed', 'cancelled'];

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
    });

    _appointments = await _dbService.getAppointments();
    _filterAppointments();

    setState(() {
      _isLoading = false;
    });
  }

  void _filterAppointments() {
    if (_selectedFilter == 'All') {
      _filteredAppointments = _appointments;
    } else {
      _filteredAppointments = _appointments
          .where((app) => app.status == _selectedFilter)
          .toList();
    }
    setState(() {});
  }

  Future<void> _updateStatus(String id, String newStatus) async {
    await _dbService.updateAppointmentStatus(id, newStatus);
    _loadAppointments();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appointment ${newStatus}d successfully')),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'scheduled':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAppointments,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter.toUpperCase()),
                      selected: _selectedFilter == filter,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                          _filterAppointments();
                        });
                      },
                      selectedColor: Colors.blue,
                      labelStyle: TextStyle(
                        color: _selectedFilter == filter ? Colors.white : Colors.black,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Appointments List
          _isLoading
              ? const Expanded(
            child: Center(child: CircularProgressIndicator()),
          )
              : _filteredAppointments.isEmpty
              ? Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No appointments found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + button to book an appointment',
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          )
              : Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _filteredAppointments.length,
              itemBuilder: (context, index) {
                AppointmentModel appointment = _filteredAppointments[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text(
                        appointment.patientName.isNotEmpty ? appointment.patientName[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      appointment.patientName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Doctor: ${appointment.doctorName}'),
                        Text('Date: ${DateFormat('dd/MM/yyyy').format(appointment.date)} at ${appointment.time}'),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(appointment.status)
                            .withOpacity(0.2),
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
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Symptoms:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(appointment.symptoms),
                            const SizedBox(height: 12),
                            const Text(
                              'Prescription:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(appointment.prescription.isEmpty
                                ? 'Not prescribed yet'
                                : appointment.prescription),
                            const SizedBox(height: 16),
                            if (appointment.status == 'scheduled')
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => _updateStatus(
                                          appointment.id, 'completed'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),
                                      child: const Text('Complete'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => _updateStatus(
                                          appointment.id, 'cancelled'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: const Text('Cancel'),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BookAppointmentScreen()),
          );
          _loadAppointments();
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
