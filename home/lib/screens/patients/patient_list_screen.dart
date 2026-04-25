import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/database_service.dart';
import '../../models/patient_model.dart';
import 'add_patient_screen.dart';
import 'patient_detail_screen.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final DatabaseService _dbService = DatabaseService();
  List<PatientModel> _patients = [];
  List<PatientModel> _filteredPatients = [];
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPatients();
    _searchController.addListener(_filterPatients);
  }

  Future<void> _loadPatients() async {
    setState(() {
      _isLoading = true;
    });

    _patients = await _dbService.getPatients();
    _filteredPatients = _patients;

    setState(() {
      _isLoading = false;
    });
  }

  void _filterPatients() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPatients = _patients.where((patient) {
        return patient.name.toLowerCase().contains(query) ||
            patient.contact.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPatients,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or phone',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
                    : null,
              ),
            ),
          ),
          _isLoading
              ? const Expanded(
            child: Center(child: CircularProgressIndicator()),
          )
              : _filteredPatients.isEmpty
              ? Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No patients found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + button to add a patient',
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
              itemCount: _filteredPatients.length,
              itemBuilder: (context, index) {
                PatientModel patient = _filteredPatients[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text(
                        patient.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      patient.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Age: ${patient.age} years'),
                        Text('Contact: ${patient.contact}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit,
                              color: Colors.blue),
                          onPressed: () => _editPatient(patient),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.red),
                          onPressed: () => _deletePatient(patient.id),
                        ),
                      ],
                    ),
                    onTap: () => _viewPatient(patient),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addPatient(),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _addPatient() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddPatientScreen()),
    );
    _loadPatients();
  }

  void _editPatient(PatientModel patient) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPatientScreen(patient: patient),
      ),
    );
    _loadPatients();
  }

  void _viewPatient(PatientModel patient) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientDetailScreen(patient: patient),
      ),
    );
  }

  Future<void> _deletePatient(String id) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Patient'),
        content: const Text('Are you sure you want to delete this patient?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _dbService.deletePatient(id);
              _loadPatients();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Patient deleted successfully')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}