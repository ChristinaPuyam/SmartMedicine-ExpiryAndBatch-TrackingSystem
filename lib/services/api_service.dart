import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:3000';

  // ============================================================
  // ADMIN LOGIN
  // ============================================================


  static Future<Map<String, dynamic>> login(
      String email,
      String password,
      ) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      )
          .timeout(const Duration(seconds: 10));

      print('LOGIN STATUS: ${response.statusCode}');
      print('LOGIN RESPONSE: ${response.body}');

      final data =
      jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200) {
        throw Exception(
          data['message'] ?? 'Login request failed',
        );
      }

      return data;
    } on Exception catch (e) {
      print('LOGIN ERROR: $e');
      rethrow;
    }
  }

  // ============================================================
  // GET ALL MEDICINES
  // ============================================================

  static Future<List<dynamic>> getMedicines() async {
    final response = await http.get(
      Uri.parse('$baseUrl/medicines'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        return data['medicines'];
      }
    }

    throw Exception('Failed to load medicines');
  }

  // ============================================================
  // GET ALL SUPPLIERS
  // ============================================================

  static Future<List<dynamic>> getSuppliers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/suppliers'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        return data['suppliers'];
      }
    }

    throw Exception('Failed to load suppliers');
  }

  // ============================================================
  // GET ALL STORES
  // ============================================================

  static Future<List<dynamic>> getStores() async {
    final response = await http.get(
      Uri.parse('$baseUrl/stores'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        return data['stores'];
      }
    }

    throw Exception('Failed to load stores');
  }

  // ============================================================
  // GET ALL BATCHES
  // ============================================================

  static Future<List<dynamic>> getBatches() async {
    final response = await http.get(
      Uri.parse('$baseUrl/batches'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        return data['batches'];
      }
    }

    throw Exception('Failed to load batches');
  }

  // ============================================================
  // ADD NEW BATCH
  // ============================================================

  static Future<Map<String, dynamic>> addBatch({
    required int medicineId,
    required int supplierId,
    required int storeId,
    required String batchNumber,
    required String manufactureDate,
    required String expiryDate,
    required int quantityReceived,
    required double costPrice,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/batches'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'medicine_id': medicineId,
        'supplier_id': supplierId,
        'store_id': storeId,
        'batch_number': batchNumber,
        'manufacture_date': manufactureDate,
        'expiry_date': expiryDate,
        'quantity_received': quantityReceived,
        'cost_price': costPrice,
      }),
    );

    return jsonDecode(response.body);
  }

  // ============================================================
  // GET DASHBOARD SUMMARY
  // ============================================================

  static Future<Map<String, dynamic>> getDashboard() async {
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard'),
    );

    if (response.statusCode == 200) {
      final data =
      jsonDecode(response.body) as Map<String, dynamic>;

      if (data['success'] == true) {
        return Map<String, dynamic>.from(data['summary']);
      }
    }

    throw Exception('Failed to load dashboard summary');
  }

  // ============================================================
  // GET EXPIRY ALERTS
  // ============================================================

  static Future<List<dynamic>> getExpiryAlerts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/expiry-alerts'),
    );

    if (response.statusCode == 200) {
      final data =
      jsonDecode(response.body) as Map<String, dynamic>;

      if (data['success'] == true) {
        return data['alerts'] as List<dynamic>;
      }
    }

    throw Exception('Failed to load expiry alerts');
  }static Future<Map<String, dynamic>> addMedicine({
    required String medicineName,
    required String category,
    required String manufacturer,
    required String description,
    required String barcode,
  }) async {
    final response = await http
        .post(
      Uri.parse('$baseUrl/medicines'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'medicine_name': medicineName,
        'category': category,
        'manufacturer': manufacturer,
        'description': description,
        'barcode': barcode,
      }),
    )
        .timeout(const Duration(seconds: 10));

    final data =
    jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 201 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to save medicine');
    }

    return data;
  }
}