import 'package:flutter/material.dart';

class ExpiryAlertPage extends StatelessWidget {
  const ExpiryAlertPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Expiry Alerts'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),

      body: ListView(

        padding: const EdgeInsets.all(16),

        children: [

          const Text(
            'Medicine Expiry Status',
            style: TextStyle(
              fontSize: 24,
              fontWeight:
              FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Card(

            color: Colors.red.shade50,

            child: const ListTile(

              leading: Icon(
                Icons.error,
                color: Colors.red,
                size: 40,
              ),

              title: Text(
                'Paracetamol',
                style: TextStyle(
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              subtitle: Text(
                'Batch: PCM001\n'
                    'Expiry Date: 10 Aug 2026\n'
                    'Status: EXPIRED',
              ),

              trailing: Icon(
                Icons.warning,
                color: Colors.red,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Card(

            color: Colors.orange.shade50,

            child: const ListTile(

              leading: Icon(
                Icons.warning_amber,
                color: Colors.orange,
                size: 40,
              ),

              title: Text(
                'Amoxicillin',
                style: TextStyle(
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              subtitle: Text(
                'Batch: AMX002\n'
                    'Expiry Date: 05 Sep 2026\n'
                    'Status: EXPIRING SOON',
              ),

              trailing: Icon(
                Icons.access_time,
                color: Colors.orange,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Card(

            color: Colors.green.shade50,

            child: const ListTile(

              leading: Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 40,
              ),

              title: Text(
                'Vitamin C',
                style: TextStyle(
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              subtitle: Text(
                'Batch: VTC003\n'
                    'Expiry Date: 15 Dec 2027\n'
                    'Status: SAFE',
              ),

              trailing: Icon(
                Icons.check_circle_outline,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}