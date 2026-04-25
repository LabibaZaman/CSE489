// lib/screens/reports_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final DatabaseService _dbService = DatabaseService();

  // Dashboard Stats
  int _totalPatients = 0;
  int _totalAppointments = 0;
  int _totalMedicines = 0;
  double _totalRevenue = 0;
  int _pendingInvoices = 0;
  int _lowStockCount = 0;

  // Weekly/Monthly Data
  List<Map<String, dynamic>> _weeklyAppointments = [];
  List<Map<String, dynamic>> _monthlyRevenue = [];

  bool _isLoading = true;
  String _selectedPeriod = 'This Week';

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);

    try {
      _totalPatients = await _dbService.getTotalPatients();
      _totalAppointments = (await _dbService.getAppointments()).length;
      _totalMedicines = (await _dbService.getMedicines()).length;
      _totalRevenue = await _dbService.getTotalRevenue();
      _pendingInvoices = (await _dbService.getInvoices()).where((i) => i.status == 'pending').length;
      _lowStockCount = (await _dbService.getLowStockMedicines()).length;

      await _loadWeeklyData();
      await _loadMonthlyData();
    } catch (e) {
      print('Error loading reports: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _loadWeeklyData() async {
    // Get last 7 days appointments
    List<Map<String, dynamic>> weekData = [];
    DateTime today = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      DateTime date = DateTime(today.year, today.month, today.day - i);
      String dayName = DateFormat('EEE').format(date);

      var appointments = await _dbService.getAppointments();
      int count = appointments.where((a) =>
      a.date.year == date.year &&
          a.date.month == date.month &&
          a.date.day == date.day
      ).length;

      weekData.add({'day': dayName, 'count': count, 'date': date});
    }

    setState(() => _weeklyAppointments = weekData);
  }

  Future<void> _loadMonthlyData() async {
    List<Map<String, dynamic>> monthData = [];
    DateTime now = DateTime.now();
    DateTime startOfYear = DateTime(now.year, 1, 1);

    for (int i = 0; i < 12; i++) {
      DateTime month = DateTime(now.year, i + 1, 1);
      var invoices = await _dbService.getInvoices();
      double revenue = invoices
          .where((inv) =>
      inv.date.year == month.year &&
          inv.date.month == month.month &&
          inv.status == 'paid')
          .fold(0, (sum, inv) => sum + inv.amount);

      monthData.add({
        'month': DateFormat('MMM').format(month),
        'revenue': revenue,
      });
    }

    setState(() => _monthlyRevenue = monthData);
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
        title: const Text('Reports & Analytics'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Summary Cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildSummaryCard('Total Patients', _totalPatients, Icons.people, Colors.blue),
                _buildSummaryCard('Total Revenue', '₹${_totalRevenue.toStringAsFixed(0)}', Icons.currency_rupee, Colors.green),
                _buildSummaryCard('Appointments', _totalAppointments, Icons.calendar_today, Colors.orange),
                _buildSummaryCard('Medicines', _totalMedicines, Icons.medication, Colors.purple),
                _buildSummaryCard('Pending Invoices', _pendingInvoices, Icons.receipt, Colors.red),
                _buildSummaryCard('Low Stock Items', _lowStockCount, Icons.warning, _lowStockCount > 0 ? Colors.orange : Colors.grey),
              ],
            ),
            const SizedBox(height: 24),

            // Weekly Appointments Chart
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Weekly Appointments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: _weeklyAppointments.map((data) {
                          int maxCount = _weeklyAppointments.fold(0, (max, d) => (d['count'] as int) > max ? d['count'] : max);
                          double height = maxCount > 0 ? (data['count'] / maxCount) * 150 : 0;

                          return Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  height: height,
                                  width: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      data['count'].toString(),
                                      style: const TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(data['day'], style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Monthly Revenue Chart
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Monthly Revenue (₹)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: _monthlyRevenue.map((data) {
                          double maxRevenue = _monthlyRevenue.fold(0.0, (max, d) => (d['revenue'] as double) > max ? d['revenue'] : max);
                          double height = maxRevenue > 0 ? (data['revenue'] / maxRevenue) * 150 : 0;

                          return Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  height: height,
                                  width: 30,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.green, Colors.green[700]!],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '₹${(data['revenue'] as double).toInt()}',
                                      style: const TextStyle(color: Colors.white, fontSize: 10),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(data['month'], style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Key Insights
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Key Insights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildInsightRow(
                      'Average Revenue per Patient',
                      _totalPatients > 0 ? '₹${(_totalRevenue / _totalPatients).toStringAsFixed(2)}' : '₹0',
                      Icons.trending_up,
                    ),
                    const Divider(),
                    _buildInsightRow(
                      'Appointment Completion Rate',
                      _totalAppointments > 0 ? '${((_totalAppointments - _pendingInvoices) / _totalAppointments * 100).toInt()}%' : '0%',
                      Icons.check_circle,
                    ),
                    const Divider(),
                    _buildInsightRow(
                      'Inventory Health',
                      _totalMedicines > 0 ? '${((_totalMedicines - _lowStockCount) / _totalMedicines * 100).toInt()}% Healthy' : '0%',
                      Icons.inventory,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, dynamic value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightRow(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 14))),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
        ],
      ),
    );
  }
}