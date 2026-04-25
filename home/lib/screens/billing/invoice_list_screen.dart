// lib/screens/billing/invoice_list_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/database_service.dart';
import '../../models/invoice_model.dart';
import 'generate_invoice_screen.dart';
import 'invoice_detail_screen.dart';

class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {
  final DatabaseService _dbService = DatabaseService();
  List<InvoiceModel> _invoices = [];
  List<InvoiceModel> _filteredInvoices = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'paid', 'pending'];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInvoices();
    _searchController.addListener(_filterInvoices);
  }

  Future<void> _loadInvoices() async {
    setState(() => _isLoading = true);
    _invoices = await _dbService.getInvoices();
    _filterInvoices();
    setState(() => _isLoading = false);
  }

  void _filterInvoices() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredInvoices = _invoices.where((invoice) {
        bool matchesFilter = _selectedFilter == 'All' || invoice.status == _selectedFilter;
        bool matchesSearch = invoice.patientName.toLowerCase().contains(query) ||
            invoice.id.toLowerCase().contains(query);
        return matchesFilter && matchesSearch;
      }).toList();
    });
  }

  Future<void> _updatePaymentStatus(String id, String newStatus) async {
    await _dbService.updateInvoiceStatus(id, newStatus);
    _loadInvoices();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invoice ${newStatus == 'paid' ? 'marked as paid' : 'updated'}')),
      );
    }
  }

  Color _getStatusColor(String status) {
    return status == 'paid' ? Colors.green : Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInvoices,
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
                hintText: 'Search by patient name or invoice ID',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () => _searchController.clear())
                    : null,
              ),
            ),
          ),
          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                          _filterInvoices();
                        });
                      },
                      selectedColor: Colors.blue,
                      labelStyle: TextStyle(color: _selectedFilter == filter ? Colors.white : Colors.black),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Stats Summary
          _buildStatsSummary(),
          const SizedBox(height: 8),
          // Invoices List
          _isLoading
              ? const Expanded(child: Center(child: CircularProgressIndicator()))
              : _filteredInvoices.isEmpty
              ? Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('No invoices found', style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _generateInvoice(),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text('Generate Invoice'),
                  ),
                ],
              ),
            ),
          )
              : Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _filteredInvoices.length,
              itemBuilder: (context, index) {
                InvoiceModel invoice = _filteredInvoices[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text(invoice.patientName[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                    ),
                    title: Text(invoice.patientName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Invoice #${invoice.id.substring(0, 8)}'),
                        Text('Date: ${DateFormat('dd/MM/yyyy').format(invoice.date)}'),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('₹${invoice.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStatusColor(invoice.status).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(invoice.status.toUpperCase(), style: TextStyle(color: _getStatusColor(invoice.status), fontSize: 10)),
                        ),
                      ],
                    ),
                    onTap: () => _viewInvoiceDetail(invoice),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _generateInvoice,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatsSummary() {
    int totalInvoices = _invoices.length;
    double totalRevenue = _invoices.where((i) => i.status == 'paid').fold(0, (sum, i) => sum + i.amount);
    int pendingCount = _invoices.where((i) => i.status == 'pending').length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', totalInvoices.toString(), Icons.receipt),
          Container(width: 1, height: 40, color: Colors.grey[300]),
          _buildStatItem('Revenue', '₹${totalRevenue.toStringAsFixed(0)}', Icons.currency_rupee),
          Container(width: 1, height: 40, color: Colors.grey[300]),
          _buildStatItem('Pending', pendingCount.toString(), Icons.pending),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  void _generateInvoice() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => const GenerateInvoiceScreen()));
    _loadInvoices();
  }

  void _viewInvoiceDetail(InvoiceModel invoice) async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => InvoiceDetailScreen(invoice: invoice)));
    if (result == true) _loadInvoices();
  }
}