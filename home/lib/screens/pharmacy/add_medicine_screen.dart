import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../models/medicine_model.dart';

class AddMedicineScreen extends StatefulWidget {
  final MedicineModel? medicine;
  const AddMedicineScreen({super.key, this.medicine});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final DatabaseService _dbService = DatabaseService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _stockController;
  late TextEditingController _priceController;
  late TextEditingController _expiryController;
  late TextEditingController _manufacturerController;

  final List<String> _categories = [
    'Painkiller',
    'Antibiotic',
    'Antihistamine',
    'Vitamin',
    'Homeopathy',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medicine?.name ?? '');
    _categoryController = TextEditingController(text: widget.medicine?.category ?? '');
    _stockController = TextEditingController(text: widget.medicine?.stock.toString() ?? '');
    _priceController = TextEditingController(text: widget.medicine?.price.toString() ?? '');
    _expiryController = TextEditingController(text: widget.medicine?.expiryDate ?? '');
    _manufacturerController = TextEditingController(text: widget.medicine?.manufacturer ?? '');
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _expiryController.text = '${picked.year}-${picked.month}-${picked.day}';
      });
    }
  }

  Future<void> _saveMedicine() async {
    if (_formKey.currentState!.validate()) {
      String id = widget.medicine?.id ?? DateTime.now().millisecondsSinceEpoch.toString();

      MedicineModel medicine = MedicineModel(
        id: id,
        name: _nameController.text,
        category: _categoryController.text,
        stock: int.parse(_stockController.text),
        price: double.parse(_priceController.text),
        expiryDate: _expiryController.text,
        manufacturer: _manufacturerController.text,
        createdAt: widget.medicine?.createdAt ?? DateTime.now(),
      );

      if (widget.medicine == null) {
        await _dbService.addMedicine(medicine);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medicine added successfully')),
        );
      } else {
        await _dbService.updateMedicineStock(medicine.id, medicine.stock);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medicine updated successfully')),
        );
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.medicine == null ? 'Add Medicine' : 'Edit Medicine'),
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
                  labelText: 'Medicine Name',
                  prefixIcon: Icon(Icons.medication),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Enter medicine name' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _categoryController.text.isEmpty ? null : _categoryController.text,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _categoryController.text = value!;
                  });
                },
                validator: (value) => value == null ? 'Select category' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _manufacturerController,
                decoration: const InputDecoration(
                  labelText: 'Manufacturer',
                  prefixIcon: Icon(Icons.business),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Enter manufacturer' : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      decoration: const InputDecoration(
                        labelText: 'Stock',
                        prefixIcon: Icon(Icons.inventory),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Enter stock' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        prefixIcon: Icon(Icons.currency_rupee),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Enter price' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _expiryController,
                decoration: InputDecoration(
                  labelText: 'Expiry Date',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.date_range),
                    onPressed: _selectDate,
                  ),
                ),
                readOnly: true,
                validator: (value) => value!.isEmpty ? 'Select expiry date' : null,
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _saveMedicine,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Save Medicine',
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
    _categoryController.dispose();
    _stockController.dispose();
    _priceController.dispose();
    _expiryController.dispose();
    _manufacturerController.dispose();
    super.dispose();
  }
}