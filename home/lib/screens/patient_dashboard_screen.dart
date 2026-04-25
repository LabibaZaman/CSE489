import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import 'login_screen.dart';
import 'my_appointments_screen.dart';
import 'my_invoices_screen.dart';

class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();

  String _userName = '';
  String _userEmail = '';
  int _myAppointments = 0;
  double _myBills = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadStats();
  }

  Future<void> _loadUserData() async {
    User? user = _authService.getCurrentUser();
    if (user != null) {
      Map<String, dynamic>? userData = await _authService.getUserData(user.uid);
      if (userData != null && mounted) {
        setState(() {
          _userName = userData['name'] ?? 'Patient';
          _userEmail = userData['email'] ?? '';
        });
      }
    }
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);

    try {
      var patients = await _dbService.getPatients();

      // Find patient by name or email
      var myPatient = patients.isEmpty
          ? null
          : patients.firstWhere(
            (p) => p.name.toLowerCase() == _userName.toLowerCase() ||
            p.contact == _userEmail.split('@').first,
        orElse: () => patients.first,
      );

      if (myPatient != null) {
        var appointments = await _dbService.getAppointmentsByPatient(myPatient.id);
        var invoices = await _dbService.getInvoicesByPatient(myPatient.id);

        setState(() {
          _myAppointments = appointments.length;
          _myBills = invoices.fold(0.0, (sum, inv) => sum + inv.amount);
        });
      }
    } catch (e) {
      print('Error loading stats: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Welcome Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blue, Color.fromARGB(255, 26, 115, 232)],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 45, color: Colors.blue),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _userEmail,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'PATIENT',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'My Appointments',
                    _myAppointments.toString(),
                    Icons.calendar_today,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Total Bills',
                    '₹${_myBills.toStringAsFixed(2)}',
                    Icons.receipt,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _buildActionCard(
              'My Appointments',
              Icons.calendar_month,
              Colors.blue,
                  () {
                Navigator.pushNamed(context, '/my_appointments');
              },
            ),
            const SizedBox(height: 10),

            _buildActionCard(
              'My Invoices',
              Icons.receipt_long,
              Colors.green,
                  () {
                Navigator.pushNamed(context, '/my_invoices');
              },
            ),
            const SizedBox(height: 10),

            _buildActionCard(
              'Book New Appointment',
              Icons.calendar_month,
              Colors.orange,
                  () {
                Navigator.pushNamed(context, '/book_appointment');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Icon(icon, size: 35, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 30, color: color),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}