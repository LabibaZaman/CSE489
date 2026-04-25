// lib/screens/pharmacy/medicine_list_screen.dart
import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../models/medicine_model.dart';
import 'add_medicine_screen.dart';

class MedicineListScreen extends StatefulWidget {
  const MedicineListScreen({super.key});

  @override
  State<MedicineListScreen> createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends State<MedicineListScreen> {
  final DatabaseService _dbService = DatabaseService();
  List<MedicineModel> _medicines = [];
  List<MedicineModel> _filteredMedicines = [];
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  List<String> _categories = ['All'];

  @override
  void initState() {
    super.initState();
    _loadMedicines();
    _searchController.addListener(_filterMedicines);
  }

  Future<void> _loadMedicines() async {
    setState(() => _isLoading = true);
    _medicines = await _dbService.getMedicines();

    // Extract unique categories
    Set<String> cats = {'All'};
    for (var m in _medicines) {
      if (m.category.isNotEmpty) cats.add(m.category);
    }
    _categories = cats.toList();

    _filterMedicines();
    setState(() => _isLoading = false);
  }

  void _filterMedicines() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMedicines = _medicines.where((medicine) {
        bool matchesSearch = medicine.name.toLowerCase().contains(query) ||
            medicine.manufacturer.toLowerCase().contains(query);
        bool matchesCategory = _selectedCategory == 'All' || medicine.category == _selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  Future<void> _updateStock(MedicineModel medicine, int newStock) async {
    if (newStock < 0) return;
    await _dbService.updateMedicineStock(medicine.id, newStock);
    _loadMedicines();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${medicine.name} stock updated to $newStock')),
    );
  }

  Future<void> _deleteMedicine(MedicineModel medicine) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Medicine'),
        content: Text('Are you sure you want to delete ${medicine.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _dbService.deleteMedicine(medicine.id);
              _loadMedicines();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Medicine deleted successfully')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _editMedicine(MedicineModel medicine) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => AddMedicineScreen(medicine: medicine)));
    _loadMedicines();
  }

  void _addMedicine() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddMedicineScreen()));
    _loadMedicines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pharmacy'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadMedicines),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or manufacturer',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () => _searchController.clear())
                    : null,
              ),
            ),
          ),
          // Category Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: _categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                        _filterMedicines();
                      });
                    },
                    selectedColor: Colors.blue,
                    labelStyle: TextStyle(color: _selectedCategory == category ? Colors.white : Colors.black),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          // Stats Summary
          _buildStatsSummary(),
          // Medicine List
          _isLoading
              ? const Expanded(child: Center(child: CircularProgressIndicator()))
              : _filteredMedicines.isEmpty
              ? Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.medication, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('No medicines found', style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _addMedicine,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text('Add Medicine'),
                  ),
                ],
              ),
            ),
          )
              : Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _filteredMedicines.length,
              itemBuilder: (context, index) {
                MedicineModel medicine = _filteredMedicines[index];
                bool isLowStock = medicine.stock < 20;
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: isLowStock ? Colors.orange : Colors.blue,
                      child: Text(medicine.name[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                    ),
                    title: Row(
                      children: [
                        Expanded(child: Text(medicine.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                        if (isLowStock)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('Low Stock', style: TextStyle(color: Colors.orange, fontSize: 10)),
                          ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Category: ${medicine.category}'),
                        Text('Stock: ${medicine.stock} units | Price: ₹${medicine.price}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editMedicine(medicine),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteMedicine(medicine),
                        ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow('Manufacturer', medicine.manufacturer),
                            _buildInfoRow('Expiry Date', medicine.expiryDate),
                            _buildInfoRow('Created', '${medicine.createdAt.day}/${medicine.createdAt.month}/${medicine.createdAt.year}'),
                            const SizedBox(height: 12),
                            const Text('Update Stock', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                                  onPressed: () => _updateStock(medicine, medicine.stock - 1),
                                ),
                                Text(medicine.stock.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle, color: Colors.green),
                                  onPressed: () => _updateStock(medicine, medicine.stock + 1),
                                ),
                                const SizedBox(width: 16),
                                SizedBox(
                                  width: 80,
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      labelText: 'Set',
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                    keyboardType: TextInputType.number,
                                    onSubmitted: (value) {
                                      int newStock = int.tryParse(value) ?? medicine.stock;
                                      _updateStock(medicine, newStock);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMedicine,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatsSummary() {
    int totalMedicines = _medicines.length;
    int lowStockCount = _medicines.where((m) => m.stock < 20).length;
    double totalValue = _medicines.fold(0, (sum, m) => sum + (m.price * m.stock));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', totalMedicines.toString(), Icons.medication),
          _buildStatItem('Low Stock', lowStockCount.toString(), Icons.warning, lowStockCount > 0 ? Colors.orange : null),
          _buildStatItem('Inventory Value', '₹${totalValue.toStringAsFixed(0)}', Icons.currency_rupee),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, [Color? color]) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color ?? Colors.blue),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12))),
          Text(':  $value', style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}