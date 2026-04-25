// lib/screens/billing/invoice_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/database_service.dart';
import '../../models/invoice_model.dart';
import '../../services/pdf_service.dart';

class InvoiceDetailScreen extends StatefulWidget {
  final InvoiceModel invoice;
  const InvoiceDetailScreen({super.key, required this.invoice});

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  final DatabaseService _dbService = DatabaseService();
  late InvoiceModel _invoice;

  @override
  void initState() {
    super.initState();
    _invoice = widget.invoice;
  }

  Future<void> _updatePaymentStatus(String newStatus) async {
    await _dbService.updateInvoiceStatus(_invoice.id, newStatus);
    setState(() {
      _invoice.status = newStatus;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment marked as $newStatus')),
    );
  }

  Future<void> _downloadPDF() async {
    await PdfService.generateInvoicePDF(_invoice, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice #${_invoice.id.substring(0, 8)}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.picture_as_pdf), onPressed: _downloadPDF, tooltip: 'Download PDF'),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.blue, Color.fromARGB(255, 26, 115, 232)]),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  const Icon(Icons.receipt, size: 50, color: Colors.white),
                  const SizedBox(height: 10),
                  const Text('INVOICE', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('Date: ${DateFormat('dd/MM/yyyy hh:mm a').format(_invoice.date)}', style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Patient & Billing Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Patient Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const Divider(),
                    _buildInfoRow('Patient Name', _invoice.patientName),
                    _buildInfoRow('Patient ID', _invoice.patientId.substring(0, 8)),
                    const SizedBox(height: 12),
                    const Text('Billing Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const Divider(),
                    _buildInfoRow('Payment Method', _invoice.paymentMethod),
                    _buildInfoRow('Status', _invoice.status.toUpperCase()),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Items List
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const Divider(),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _invoice.items.length,
                      itemBuilder: (context, index) {
                        var item = _invoice.items[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text(item['name'])),
                              Text('x${item['quantity']}'),
                              const SizedBox(width: 16),
                              Text('₹${item['price']}'),
                              const SizedBox(width: 16),
                              Text('₹${(item['price'] * item['quantity']).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        );
                      },
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Amount:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('₹${_invoice.amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            if (_invoice.status == 'pending')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _updatePaymentStatus('paid'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Mark as Paid', style: TextStyle(fontSize: 16)),
                ),
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _downloadPDF,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Download PDF'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Text(':  $value'),
        ],
      ),
    );
  }
}