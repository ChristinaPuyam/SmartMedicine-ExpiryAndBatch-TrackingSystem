import 'package:flutter/material.dart';
import 'services/api_service.dart';

class MedicineListPage extends StatefulWidget {
  const MedicineListPage({super.key});

  @override
  State<MedicineListPage> createState() =>
      _MedicineListPageState();
}

class _MedicineListPageState
    extends State<MedicineListPage> {

  List<dynamic> medicines = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadMedicines();
  }

  Future<void> loadMedicines() async {
    try {
      final data =
      await ApiService.getMedicines();

      if (!mounted) return;

      setState(() {
        medicines = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error loading medicines: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine List'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),

      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : medicines.isEmpty
          ? const Center(
        child: Text(
          'No medicines found',
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      )
          : RefreshIndicator(
        onRefresh: loadMedicines,

        child: ListView.builder(
          padding: const EdgeInsets.all(15),

          itemCount: medicines.length,

          itemBuilder: (context, index) {
            final medicine = medicines[index];

            return Card(
              elevation: 4,

              margin:
              const EdgeInsets.only(
                bottom: 15,
              ),

              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor:
                  Colors.teal,

                  child: Icon(
                    Icons.medication,
                    color: Colors.white,
                  ),
                ),

                title: Text(
                  medicine['medicine_name'] ??
                      'Unknown Medicine',

                  style: const TextStyle(
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                subtitle: Text(
                  'Category: '
                      '${medicine['category'] ?? 'Not specified'}\n'
                      'Manufacturer: '
                      '${medicine['manufacturer'] ?? 'Not specified'}\n'
                      'Generic Name: '
                      '${medicine['generic_name'] ?? 'Not specified'}\n'
                      'Price: ₹'
                      '${medicine['unit_price'] ?? '0'}',
                ),

                trailing:
                PopupMenuButton<String>(
                  itemBuilder:
                      (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),

                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],

                  onSelected: (value) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      SnackBar(
                        content: Text(
                          '$value selected for '
                              '${medicine['medicine_name']}',
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}