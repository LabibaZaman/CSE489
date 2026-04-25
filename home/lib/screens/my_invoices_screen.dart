import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/invoice_model.dart';

class MyInvoicesScreen extends StatefulWidget {
  const MyInvoicesScreen({super.key});

  @override
  State<MyInvoicesScreen> createState() => _MyInvoicesScreenState();
}

class _MyInvoicesScreenState extends State<MyInvoicesScreen> {
  final DatabaseService _dbService = DatabaseService();
  final AuthService _authService = AuthService();

  List<InvoiceModel> _invoices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMyInvoices();
  }

  Future<void> _loadMyInvoices() async {
    setState(() => _isLoading = true);

    try {
      String? userId = _authService.getCurrentUserId();
      if (userId != null) {
        var patients = await _dbService.getPatients();
        var myPatient = patients.firstWhere(
              (p) => p.contact == _authService.getCurrentUser()?.email?.split('@').first,
          orElse: () => patients.first,
        );

        _invoices = await _dbService.getInvoicesByPatient(myPatient.id);
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Invoices'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _invoices.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No invoices found', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _invoices.length,
        itemBuilder: (context, index) {
          final invoice = _invoices[index];
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Invoice #${invoice.id.substring(0, 8)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: invoice.status == 'paid'
                              ? Colors.green.withOpacity(0.2)
                              : Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          invoice.status.toUpperCase(),
                          style: TextStyle(
                            color: invoice.status == 'paid' ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Date: ${DateFormat('dd/MM/yyyy').format(invoice.date)}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const Divider(),
                  ...invoice.items.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${item['name']} x ${item['quantity']}'),
                        Text('₹${(item['price'] * item['quantity']).toStringAsFixed(2)}'),
                      ],
                    ),
                  )),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                        '₹${invoice.amount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Payment Method: ${invoice.paymentMethod}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
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