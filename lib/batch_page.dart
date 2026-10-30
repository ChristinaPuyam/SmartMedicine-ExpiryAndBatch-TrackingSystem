import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'add_batch_page.dart';

class BatchPage extends StatefulWidget {
  const BatchPage({super.key});

  @override
  State<BatchPage> createState() => _BatchPageState();
}

class _BatchPageState extends State<BatchPage> {

  List<dynamic> batches = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadBatches();
  }

  // =====================================================
  // LOAD BATCHES
  // =====================================================

  Future<void> loadBatches() async {

    setState(() {
      isLoading = true;
    });

    try {

      final data = await ApiService.getBatches();

      if (!mounted) return;

      setState(() {
        batches = data;
        isLoading = false;
      });

    } catch (e) {

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load batches: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // =====================================================
  // STATUS COLOR
  // =====================================================

  Color statusColor(String status) {

    switch (status) {

      case 'ACTIVE':
        return Colors.green;

      case 'EXPIRED':
        return Colors.red;

      case 'RECALLED':
        return Colors.orange;

      case 'SOLD_OUT':
        return Colors.grey;

      default:
        return Colors.blue;
    }
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text('Batch Management'),

        backgroundColor: Colors.red,

        foregroundColor: Colors.white,

        actions: [

          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadBatches,
          ),

        ],
      ),

      floatingActionButton: FloatingActionButton.extended(

        backgroundColor: Colors.red,

        foregroundColor: Colors.white,

        icon: const Icon(Icons.add),

        label: const Text('Add Batch'),

        onPressed: () async {

          final result = await Navigator.push(

            context,

            MaterialPageRoute(
              builder: (context) =>
              const AddBatchPage(),
            ),
          );

          if (result == true) {
            loadBatches();
          }

        },
      ),

      body: isLoading

          ? const Center(
        child: CircularProgressIndicator(),
      )

          : batches.isEmpty

          ? Center(

        child: Column(

          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [

            const Icon(
              Icons.inventory_2_outlined,
              size: 70,
              color: Colors.grey,
            ),

            const SizedBox(height: 15),

            const Text(
              'No batches found',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton.icon(

              onPressed: () async {

                final result =
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const AddBatchPage(),
                  ),
                );

                if (result == true) {
                  loadBatches();
                }
              },

              icon: const Icon(Icons.add),

              label: const Text(
                'Add First Batch',
              ),
            ),
          ],
        ),
      )

          : RefreshIndicator(

        onRefresh: loadBatches,

        child: ListView.builder(

          padding: const EdgeInsets.all(15),

          itemCount: batches.length,

          itemBuilder: (context, index) {

            final batch = batches[index];

            final status =
                batch['status'] ?? 'ACTIVE';

            return Card(

              elevation: 4,

              margin:
              const EdgeInsets.only(
                bottom: 15,
              ),

              child: Padding(

                padding:
                const EdgeInsets.all(15),

                child: Column(

                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    // HEADER

                    Row(

                      mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,

                      children: [

                        Expanded(

                          child: Text(

                            batch[
                            'medicine_name'] ??
                                'Unknown Medicine',

                            style:
                            const TextStyle(
                              fontSize: 18,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ),

                        Container(

                          padding:
                          const EdgeInsets
                              .symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),

                          decoration:
                          BoxDecoration(

                            color: statusColor(
                                status)
                                .withOpacity(
                                0.15),

                            borderRadius:
                            BorderRadius
                                .circular(20),
                          ),

                          child: Text(

                            status,

                            style: TextStyle(

                              color:
                              statusColor(
                                  status),

                              fontWeight:
                              FontWeight.bold,

                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Divider(),

                    // BATCH NUMBER

                    Text(
                      'Batch Number: ${batch['batch_number']}',
                    ),

                    const SizedBox(height: 6),

                    // SUPPLIER

                    Text(
                      'Supplier: ${batch['supplier_name']}',
                    ),

                    const SizedBox(height: 6),

                    // STORE

                    Text(
                      'Store: ${batch['store_name']}',
                    ),

                    const SizedBox(height: 6),

                    // MANUFACTURE DATE

                    Text(
                      'Manufacture Date: ${batch['manufacture_date']}',
                    ),

                    const SizedBox(height: 6),

                    // EXPIRY DATE

                    Text(
                      'Expiry Date: ${batch['expiry_date']}',
                    ),

                    const SizedBox(height: 6),

                    // QUANTITY

                    Text(
                      'Quantity: ${batch['quantity_available']} / ${batch['quantity_received']}',
                      style:
                      const TextStyle(
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // COST

                    Text(
                      'Cost Price: ₹${batch['cost_price']}',
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}