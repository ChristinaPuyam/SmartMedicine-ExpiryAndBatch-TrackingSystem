import 'package:flutter/material.dart';
import 'services/api_service.dart';

class AddBatchPage extends StatefulWidget {
  const AddBatchPage({super.key});

  @override
  State<AddBatchPage> createState() => _AddBatchPageState();
}

class _AddBatchPageState extends State<AddBatchPage> {

  List<dynamic> medicines = [];
  List<dynamic> suppliers = [];
  List<dynamic> stores = [];

  int? selectedMedicine;
  int? selectedSupplier;
  int? selectedStore;

  final batchNumberController = TextEditingController();
  final quantityController = TextEditingController();
  final costController = TextEditingController();

  DateTime? manufactureDate;
  DateTime? expiryDate;

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // =====================================================
  // LOAD MEDICINES, SUPPLIERS AND STORES
  // =====================================================

  Future<void> loadData() async {

    try {

      final results = await Future.wait([
        ApiService.getMedicines(),
        ApiService.getSuppliers(),
        ApiService.getStores(),
      ]);

      if (!mounted) return;

      setState(() {

        medicines = results[0];
        suppliers = results[1];
        stores = results[2];

        isLoading = false;

      });

    } catch (e) {

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // =====================================================
  // DATE PICKER
  // =====================================================

  Future<void> selectManufactureDate() async {

    final date = await showDatePicker(

      context: context,

      initialDate: DateTime.now(),

      firstDate: DateTime(2000),

      lastDate: DateTime(2100),

    );

    if (date != null) {

      setState(() {
        manufactureDate = date;
      });

    }
  }

  Future<void> selectExpiryDate() async {

    final date = await showDatePicker(

      context: context,

      initialDate: DateTime.now(),

      firstDate: DateTime(2000),

      lastDate: DateTime(2100),

    );

    if (date != null) {

      setState(() {
        expiryDate = date;
      });

    }
  }

  String formatDate(DateTime date) {

    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // =====================================================
  // ADD BATCH
  // =====================================================

  Future<void> addBatch() async {

    if (selectedMedicine == null ||
        selectedSupplier == null ||
        selectedStore == null ||
        batchNumberController.text.trim().isEmpty ||
        manufactureDate == null ||
        expiryDate == null ||
        quantityController.text.trim().isEmpty ||
        costController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    final quantity =
    int.tryParse(quantityController.text.trim());

    final cost =
    double.tryParse(costController.text.trim());

    if (quantity == null || quantity <= 0) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid quantity'),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    if (cost == null || cost < 0) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid cost price'),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    if (expiryDate!.isBefore(manufactureDate!)) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Expiry date cannot be before manufacture date',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    setState(() {
      isSaving = true;
    });

    try {

      final result = await ApiService.addBatch(

        medicineId: selectedMedicine!,

        supplierId: selectedSupplier!,

        storeId: selectedStore!,

        batchNumber:
        batchNumberController.text.trim(),

        manufactureDate:
        formatDate(manufactureDate!),

        expiryDate:
        formatDate(expiryDate!),

        quantityReceived: quantity,

        costPrice: cost,

      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'] ?? 'Batch added successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add batch: $e'),
          backgroundColor: Colors.red,
        ),
      );

    } finally {

      if (mounted) {

        setState(() {
          isSaving = false;
        });

      }
    }
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Add New Batch'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),

      body: isLoading

          ? const Center(
        child: CircularProgressIndicator(),
      )

          : SingleChildScrollView(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            // MEDICINE

            DropdownButtonFormField<int>(

              value: selectedMedicine,

              decoration: const InputDecoration(
                labelText: 'Medicine',
                prefixIcon: Icon(Icons.medication),
                border: OutlineInputBorder(),
              ),

              items: medicines.map((medicine) {

                return DropdownMenuItem<int>(

                  value: medicine['medicine_id'],

                  child: Text(
                    medicine['medicine_name'],
                  ),

                );

              }).toList(),

              onChanged: (value) {

                setState(() {
                  selectedMedicine = value;
                });

              },

            ),

            const SizedBox(height: 15),

            // SUPPLIER

            DropdownButtonFormField<int>(

              value: selectedSupplier,

              decoration: const InputDecoration(
                labelText: 'Supplier',
                prefixIcon: Icon(Icons.local_shipping),
                border: OutlineInputBorder(),
              ),

              items: suppliers.map((supplier) {

                return DropdownMenuItem<int>(

                  value: supplier['supplier_id'],

                  child: Text(
                    supplier['supplier_name'],
                  ),

                );

              }).toList(),

              onChanged: (value) {

                setState(() {
                  selectedSupplier = value;
                });

              },

            ),

            const SizedBox(height: 15),

            // STORE

            DropdownButtonFormField<int>(

              value: selectedStore,

              decoration: const InputDecoration(
                labelText: 'Store',
                prefixIcon: Icon(Icons.store),
                border: OutlineInputBorder(),
              ),

              items: stores.map((store) {

                return DropdownMenuItem<int>(

                  value: store['store_id'],

                  child: Text(
                    store['store_name'],
                  ),

                );

              }).toList(),

              onChanged: (value) {

                setState(() {
                  selectedStore = value;
                });

              },

            ),

            const SizedBox(height: 15),

            // BATCH NUMBER

            TextField(

              controller: batchNumberController,

              decoration: const InputDecoration(
                labelText: 'Batch Number',
                prefixIcon: Icon(Icons.qr_code),
                border: OutlineInputBorder(),
              ),

            ),

            const SizedBox(height: 15),

            // MANUFACTURE DATE

            ListTile(

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
                side: const BorderSide(
                  color: Colors.grey,
                ),
              ),

              leading: const Icon(
                Icons.calendar_today,
              ),

              title: Text(
                manufactureDate == null
                    ? 'Select Manufacture Date'
                    : 'Manufacture: ${formatDate(manufactureDate!)}',
              ),

              onTap: selectManufactureDate,

            ),

            const SizedBox(height: 15),

            // EXPIRY DATE

            ListTile(

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
                side: const BorderSide(
                  color: Colors.grey,
                ),
              ),

              leading: const Icon(
                Icons.event_busy,
              ),

              title: Text(
                expiryDate == null
                    ? 'Select Expiry Date'
                    : 'Expiry: ${formatDate(expiryDate!)}',
              ),

              onTap: selectExpiryDate,

            ),

            const SizedBox(height: 15),

            // QUANTITY

            TextField(

              controller: quantityController,

              keyboardType: TextInputType.number,

              decoration: const InputDecoration(
                labelText: 'Quantity Received',
                prefixIcon: Icon(Icons.inventory),
                border: OutlineInputBorder(),
              ),

            ),

            const SizedBox(height: 15),

            // COST PRICE

            TextField(

              controller: costController,

              keyboardType:
              const TextInputType.numberWithOptions(
                decimal: true,
              ),

              decoration: const InputDecoration(
                labelText: 'Cost Price',
                prefixIcon: Icon(Icons.currency_rupee),
                border: OutlineInputBorder(),
              ),

            ),

            const SizedBox(height: 25),

            // SAVE BUTTON

            SizedBox(

              width: double.infinity,

              height: 52,

              child: ElevatedButton(

                onPressed:
                isSaving ? null : addBatch,

                style:
                ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),

                child: isSaving

                    ? const CircularProgressIndicator(
                  color: Colors.white,
                )

                    : const Text(
                  'ADD BATCH',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {

    batchNumberController.dispose();
    quantityController.dispose();
    costController.dispose();

    super.dispose();
  }
}