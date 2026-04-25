import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/database_service.dart';
import '../../models/invoice_model.dart';
import '../../models/patient_model.dart';
import '../../models/medicine_model.dart';

class GenerateInvoiceScreen extends StatefulWidget {
  const GenerateInvoiceScreen({super.key});

  @override
  State<GenerateInvoiceScreen> createState() => _GenerateInvoiceScreenState();
}

class _GenerateInvoiceScreenState extends State<GenerateInvoiceScreen> {
  final DatabaseService _dbService = DatabaseService();
  final _formKey = GlobalKey<FormState>();

  List<PatientModel> _patients = [];
  List<MedicineModel> _medicines = [];
  String? _selectedPatientId;
  String? _selectedPatientName;
  String _paymentMethod = 'Cash';
  double _totalAmount = 0;

  List<Map<String, dynamic>> _selectedItems = [];

  final List<String> _paymentMethods = ['Cash', 'Card', 'UPI', 'Insurance'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _patients = await _dbService.getPatients();
    _medicines = await _dbService.getMedicines();
    setState(() {});
  }

  void _addItem() {
    showDialog(
      context: context,
      builder: (context) {
        String selectedMedicineId = '';
        int quantity = 1;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Item'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Select Medicine',
                    ),
                    items: _medicines.map((medicine) {
                      return DropdownMenuItem(
                        value: medicine.id,
                        child: Text('${medicine.name} - ₹${medicine.price}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      selectedMedicineId = value!;
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                    ),
                    keyboardType: TextInputType.number,
                    initialValue: '1',
                    onChanged: (value) {
                      quantity = int.tryParse(value) ?? 1;
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedMedicineId.isNotEmpty) {
                      MedicineModel medicine = _medicines.firstWhere(
                              (m) => m.id == selectedMedicineId
                      );
                      setState(() {
                        _selectedItems.add({
                          'id': medicine.id,
                          'name': medicine.name,
                          'price': medicine.price,
                          'quantity': quantity,
                          'total': medicine.price * quantity,
                        });
                        _calculateTotal();
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _removeItem(int index) {
    setState(() {
      _selectedItems.removeAt(index);
      _calculateTotal();
    });
  }

  void _calculateTotal() {
    _totalAmount = _selectedItems.fold(0, (sum, item) => sum + (item['total'] as double));
    setState(() {});
  }

  Future<void> _generateInvoice() async {
    if (_selectedPatientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a patient')),
      );
      return;
    }

    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }

    String id = DateTime.now().millisecondsSinceEpoch.toString();

    InvoiceModel invoice = InvoiceModel(
      id: id,
      patientId: _selectedPatientId!,
      patientName: _selectedPatientName!,
      amount: _totalAmount,
      date: DateTime.now(),
      status: 'pending',
      items: _selectedItems,
      paymentMethod: _paymentMethod,
    );

    await _dbService.addInvoice(invoice);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invoice generated successfully')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Invoice'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Patient Selection
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select Patient',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              items: _patients.map((patient) {
                return DropdownMenuItem(
                  value: patient.id,
                  child: Text('${patient.name} (${patient.contact})'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPatientId = value;
                  _selectedPatientName = _patients.firstWhere(
                          (p) => p.id == value
                  ).name;
                });
              },
            ),
            const SizedBox(height: 16),

            // Items Section
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Items',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Selected Items List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _selectedItems.length,
              itemBuilder: (context, index) {
                var item = _selectedItems[index];
                return Card(
                  child: ListTile(
                    title: Text(item['name']),
                    subtitle: Text('Qty: ${item['quantity']} × ₹${item['price']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '₹${item['total']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeItem(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            if (_selectedItems.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text('No items added'),
                ),
              ),

            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _addItem,
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
            const SizedBox(height: 16),

            // Payment Method
            DropdownButtonFormField<String>(
              value: _paymentMethod,
              decoration: const InputDecoration(
                labelText: 'Payment Method',
                prefixIcon: Icon(Icons.payment),
                border: OutlineInputBorder(),
              ),
              items: _paymentMethods.map((method) {
                return DropdownMenuItem(
                  value: method,
                  child: Text(method),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _paymentMethod = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Total Amount
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Amount:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '₹${_totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _generateInvoice,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Generate Invoice',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}