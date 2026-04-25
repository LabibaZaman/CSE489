import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/database_service.dart';
import '../../models/appointment_model.dart';
import '../../models/patient_model.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final DatabaseService _dbService = DatabaseService();
  final _formKey = GlobalKey<FormState>();

  List<PatientModel> _patients = [];
  String? _selectedPatientId;
  String? _selectedPatientName;
  String _selectedDoctor = 'Dr. Smith';
  String _selectedTime = '09:00 AM';
  String _symptoms = '';
  String _prescription = '';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    try {
      final patients = await _dbService.getPatients();
      if (mounted) {
        setState(() {
          _patients = patients;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading patients: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        _showMessage('Error loading patients', Colors.red);
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _bookAppointment() async {
    // Validate form
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPatientId == null) {
      _showMessage('Please select a patient', Colors.orange);
      return;
    }

    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      // Create appointment
      final appointment = AppointmentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        patientId: _selectedPatientId!,
        patientName: _selectedPatientName!,
        doctorId: _selectedDoctor.replaceAll(' ', '_').toLowerCase(),
        doctorName: _selectedDoctor,
        date: _selectedDate,
        time: _selectedTime,
        status: 'scheduled',
        symptoms: _symptoms.trim(),
        prescription: _prescription.trim(),
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      await _dbService.addAppointment(appointment);

      _showMessage('Appointment booked successfully!', Colors.green);

      // Go back after short delay
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) Navigator.pop(context, true);
      });

    } catch (e) {
      print('Error: $e');
      _showMessage('Failed to book appointment: $e', Colors.red);
      setState(() => _isSaving = false);
    }
  }

  void _showMessage(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_patients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No patients found'),
            const SizedBox(height: 8),
            const Text('Please add patients first', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('Go Back'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildPatientDropdown(),
            const SizedBox(height: 24),
            _buildDoctorDropdown(),
            const SizedBox(height: 16),
            _buildDateTimeRow(),
            const SizedBox(height: 24),
            _buildSymptomsField(),
            const SizedBox(height: 16),
            _buildPrescriptionField(),
            const SizedBox(height: 32),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, color: Colors.blue, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Book New Appointment',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                SizedBox(height: 4),
                Text(
                  'Fill in the appointment details below',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Patient',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          ),
          hint: const Text('Choose a patient'),
          items: _patients.map((patient) {
            return DropdownMenuItem(
              value: patient.id,
              child: Text('${patient.name} (${patient.age} yrs)'),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedPatientId = value;
              final patient = _patients.firstWhere((p) => p.id == value);
              _selectedPatientName = patient.name;
            });
          },
          validator: (value) => value == null ? 'Please select a patient' : null,
        ),
      ],
    );
  }

  Widget _buildDoctorDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Doctor',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedDoctor,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          ),
          items: const [
            DropdownMenuItem(value: 'Dr. Smith', child: Text('Dr. Smith')),
            DropdownMenuItem(value: 'Dr. Johnson', child: Text('Dr. Johnson')),
            DropdownMenuItem(value: 'Dr. Williams', child: Text('Dr. Williams')),
            DropdownMenuItem(value: 'Dr. Brown', child: Text('Dr. Brown')),
            DropdownMenuItem(value: 'Dr. Jones', child: Text('Dr. Jones')),
          ],
          onChanged: (value) => setState(() => _selectedDoctor = value!),
        ),
      ],
    );
  }

  Widget _buildDateTimeRow() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Date', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Time', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedTime,
                    isExpanded: true,
                    icon: const Icon(Icons.access_time, color: Colors.blue),
                    items: const [
                      DropdownMenuItem(value: '09:00 AM', child: Text('09:00 AM')),
                      DropdownMenuItem(value: '10:00 AM', child: Text('10:00 AM')),
                      DropdownMenuItem(value: '11:00 AM', child: Text('11:00 AM')),
                      DropdownMenuItem(value: '12:00 PM', child: Text('12:00 PM')),
                      DropdownMenuItem(value: '02:00 PM', child: Text('02:00 PM')),
                      DropdownMenuItem(value: '03:00 PM', child: Text('03:00 PM')),
                      DropdownMenuItem(value: '04:00 PM', child: Text('04:00 PM')),
                      DropdownMenuItem(value: '05:00 PM', child: Text('05:00 PM')),
                    ],
                    onChanged: (value) => setState(() => _selectedTime = value!),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSymptomsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Symptoms', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          decoration: InputDecoration(
            hintText: 'Describe the symptoms',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          maxLines: 3,
          onChanged: (value) => _symptoms = value,
          validator: (value) => (value == null || value.isEmpty) ? 'Please enter symptoms' : null,
        ),
      ],
    );
  }

  Widget _buildPrescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Prescription (Optional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          decoration: InputDecoration(
            hintText: 'Add prescription or notes',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          maxLines: 3,
          onChanged: (value) => _prescription = value,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _bookAppointment,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: _isSaving
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : const Text('Book Appointment', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}