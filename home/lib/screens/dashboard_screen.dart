import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import 'login_screen.dart';
import 'patient_dashboard_screen.dart';
import 'patients/patient_list_screen.dart';
import 'appointments/appointment_list_screen.dart';
import 'billing/invoice_list_screen.dart';
import 'pharmacy/medicine_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();

  int _selectedIndex = 0;
  String _userName = 'User';
  String _userRole = '';
  bool _isLoading = true;

  final List<Widget> _screens = [
    const HomeContent(),
    const PatientListScreen(),
    const AppointmentListScreen(),
    const InvoiceListScreen(),
    const MedicineListScreen(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Patients',
    'Appointments',
    'Billing',
    'Pharmacy',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _authService.getCurrentUser();
    if (user != null) {
      Map<String, dynamic>? userData = await _authService.getUserData(user.uid);
      if (userData != null && mounted) {
        String role = userData['role'] ?? 'patient';

        // Redirect patients to patient dashboard
        if (role == 'patient') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PatientDashboardScreen()),
          );
          return;
        }

        setState(() {
          _userName = userData['name'] ?? 'User';
          _userRole = role;
          _isLoading = false;
        });
      }
    } else {
      setState(() => _isLoading = false);
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: Colors.blue,
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _userRole.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              tileColor: _selectedIndex == 0 ? Colors.blue[50] : null,
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Patients'),
              tileColor: _selectedIndex == 1 ? Colors.blue[50] : null,
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Appointments'),
              tileColor: _selectedIndex == 2 ? Colors.blue[50] : null,
              onTap: () {
                setState(() {
                  _selectedIndex = 2;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt),
              title: const Text('Billing'),
              tileColor: _selectedIndex == 3 ? Colors.blue[50] : null,
              onTap: () {
                setState(() {
                  _selectedIndex = 3;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.medication),
              title: const Text('Pharmacy'),
              tileColor: _selectedIndex == 4 ? Colors.blue[50] : null,
              onTap: () {
                setState(() {
                  _selectedIndex = 4;
                });
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
    );
  }
}

// Home Content Widget - Dashboard Stats
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final DatabaseService _dbService = DatabaseService();

  int _totalPatients = 0;
  int _todayAppointments = 0;
  double _totalRevenue = 0;
  int _lowStockMedicines = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);

    try {
      _totalPatients = await _dbService.getTotalPatients();
      _todayAppointments = await _dbService.getTodayAppointmentsCount();
      _totalRevenue = await _dbService.getTotalRevenue();
      _lowStockMedicines = (await _dbService.getLowStockMedicines()).length;
    } catch (e) {
      print('Error loading stats: $e');
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadStats,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.blue, Color.fromARGB(255, 26, 115, 232)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Welcome to Homeopathy Clinic',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Manage patients, appointments, billing and pharmacy from one place.',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Quick Stats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              children: [
                _buildStatCard('Total Patients', _totalPatients.toString(), Icons.people, Colors.blue),
                _buildStatCard('Today\'s Appointments', _todayAppointments.toString(), Icons.calendar_today, Colors.green),
                _buildStatCard('Total Revenue', '₹${_totalRevenue.toStringAsFixed(2)}', Icons.receipt, Colors.orange),
                _buildStatCard('Low Stock Medicines', _lowStockMedicines.toString(), Icons.warning, Colors.red),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              children: [
                _buildActionCard('Add Patient', Icons.person_add, Colors.blue, () => Navigator.pushNamed(context, '/add_patient')),
                _buildActionCard('Book Appointment', Icons.calendar_month, Colors.green, () => Navigator.pushNamed(context, '/book_appointment')),
                _buildActionCard('Generate Bill', Icons.receipt_long, Colors.orange, () => Navigator.pushNamed(context, '/generate_invoice')),
                _buildActionCard('Add Medicine', Icons.medication, Colors.purple, () => Navigator.pushNamed(context, '/add_medicine')),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Recent Appointments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            FutureBuilder(
              future: _dbService.getTodayAppointments(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(child: Text('No appointments today', style: TextStyle(color: Colors.grey[600]))),
                    ),
                  );
                }
                var appointments = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: appointments.length > 5 ? 5 : appointments.length,
                  itemBuilder: (context, index) {
                    var appointment = appointments[index];
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person, size: 20)),
                      title: Text(appointment.patientName),
                      subtitle: Text('${appointment.time} - Dr. ${appointment.doctorName}'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: appointment.status == 'scheduled'
                              ? Colors.orange.withOpacity(0.2)
                              : appointment.status == 'completed'
                              ? Colors.green.withOpacity(0.2)
                              : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          appointment.status,
                          style: TextStyle(
                            color: appointment.status == 'scheduled'
                                ? Colors.orange
                                : appointment.status == 'completed'
                                ? Colors.green
                                : Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  },
                );
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(title, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
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
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 35, color: color),
              const SizedBox(height: 10),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}