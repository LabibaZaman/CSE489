import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/database_service.dart';
import '../../models/patient_model.dart';

class AddPatientScreen extends StatefulWidget {
  final PatientModel? patient;
  const AddPatientScreen({super.key, this.patient});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final DatabaseService _dbService = DatabaseService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _contactController;
  late TextEditingController _addressController;
  late TextEditingController _bloodGroupController;
  late TextEditingController _medicalHistoryController;

  String _selectedGender = 'Male';
  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.patient?.name ?? '');
    _ageController = TextEditingController(text: widget.patient?.age.toString() ?? '');
    _contactController = TextEditingController(text: widget.patient?.contact ?? '');
    _addressController = TextEditingController(text: widget.patient?.address ?? '');
    _bloodGroupController = TextEditingController(text: widget.patient?.bloodGroup ?? '');
    _medicalHistoryController = TextEditingController(text: widget.patient?.medicalHistory ?? '');
    _selectedGender = widget.patient?.gender ?? 'Male';
  }

  Future<void> _savePatient() async {
    if (_formKey.currentState!.validate()) {
      String id = widget.patient?.id ?? DateTime.now().millisecondsSinceEpoch.toString();

      PatientModel patient = PatientModel(
        id: id,
        name: _nameController.text,
        age: int.parse(_ageController.text),
        gender: _selectedGender,
        contact: _contactController.text,
        address: _addressController.text,
        bloodGroup: _bloodGroupController.text,
        medicalHistory: _medicalHistoryController.text,
        createdAt: widget.patient?.createdAt ?? DateTime.now(),
      );

      if (widget.patient == null) {
        await _dbService.addPatient(patient);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient added successfully')),
        );
      } else {
        await _dbService.updatePatient(patient);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient updated successfully')),
        );
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patient == null ? 'Add Patient' : 'Edit Patient'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ageController,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Enter age' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                        border: OutlineInputBorder(),
                      ),
                      items: _genders.map((gender) {
                        return DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(
                  labelText: 'Contact Number',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Enter contact' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _bloodGroupController.text.isEmpty ? null : _bloodGroupController.text,
                decoration: const InputDecoration(
                  labelText: 'Blood Group',
                  border: OutlineInputBorder(),
                ),
                items: _bloodGroups.map((bg) {
                  return DropdownMenuItem(
                    value: bg,
                    child: Text(bg),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _bloodGroupController.text = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _medicalHistoryController,
                decoration: const InputDecoration(
                  labelText: 'Medical History',
                  prefixIcon: Icon(Icons.history),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _savePatient,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Save Patient',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _bloodGroupController.dispose();
    _medicalHistoryController.dispose();
    super.dispose();
  }
}