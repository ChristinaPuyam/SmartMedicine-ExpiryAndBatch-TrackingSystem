
import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'medicine_list_page.dart';
import 'batch_page.dart';
import 'expiry_alert_page.dart';
import 'add_medicine_page.dart';
import 'add_batch_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Map<String, dynamic>? summary;
  int alertCount = 0;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final results = await Future.wait([
        ApiService.getDashboard(),
        ApiService.getExpiryAlerts(),
      ]);

      if (!mounted) return;

      setState(() {
        summary = results[0] as Map<String, dynamic>;
        alertCount = (results[1] as List).length;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  int count(String key) {
    return int.tryParse('${summary?[key] ?? 0}') ?? 0;
  }

  void openPage(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    ).then((_) {
      if (mounted) loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Smart Medicine',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh dashboard',
            onPressed: loadDashboard,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadDashboard,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Pharmacy Dashboard',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Manage medicines, batches and expiry dates.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(30),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (errorMessage != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.cloud_off,
                        size: 38,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 8),
                      const Text('Unable to load dashboard'),
                      Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: loadDashboard,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.3,
                  children: [
                    _statCard(
                      'Medicines',
                      count('total_medicines'),
                      Icons.medication,
                      Colors.blue,
                    ),
                    _statCard(
                      'Active Batches',
                      count('active_batches'),
                      Icons.inventory_2,
                      Colors.teal,
                    ),
                    _statCard(
                      'Expired Batches',
                      count('expired_batches'),
                      Icons.warning_amber,
                      Colors.red,
                    ),
                    _statCard(
                      'Near Expiry',
                      count('near_expiry_batches'),
                      Icons.calendar_month,
                      Colors.orange,
                    ),
                    _statCard(
                      'Low Stock Batches',
                      count('low_stock_batches'),
                      Icons.production_quantity_limits,
                      Colors.deepPurple,
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.notifications_active,
                      color: Colors.red,
                    ),
                    title: const Text('Expiry Alerts'),
                    subtitle: Text(
                      '$alertCount batches need expiry review',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => openPage(
                      const ExpiryAlertPage(),
                    ),
                  ),
                ),
              ],

            const SizedBox(height: 20),
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            _actionTile(
              Icons.add_circle,
              'Add Medicine',
                  () => openPage(const AddMedicinePage()),
            ),
            _actionTile(
              Icons.medication,
              'Medicine List',
                  () => openPage(const MedicineListPage()),
            ),
            _actionTile(
              Icons.inventory_2,
              'Manage Batches',
                  () => openPage(const BatchPage()),
            ),
            _actionTile(
              Icons.add_box,
              'Receive New Batch',
                  () => openPage(const AddBatchPage()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(
      String title,
      int value,
      IconData icon,
      Color color,
      ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 29),
            const SizedBox(height: 9),
            Text(
              '$value',
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionTile(
      IconData icon,
      String title,
      VoidCallback onTap,
      ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.red),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}