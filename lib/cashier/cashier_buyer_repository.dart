import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../models/cashier_buyer_lookup.dart';
import '../models/cashier_history_models.dart';

class CashierBuyerRepository {
  CashierBuyerRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<CashierBuyerLookupResult> lookupBuyerByNfc(String nfcId) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/vehicle-ownerships/cashier/by-nfc/$nfcId',
      );

      final payload = response.data;
      if (payload == null) {
        throw Exception('Backend tidak mengembalikan data pembeli.');
      }

      return CashierBuyerLookupResult.fromJson(payload);
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<List<Map<String, dynamic>>> getSubsidizedFuels() async {
    try {
      final response = await _apiClient.dio.get<List<dynamic>>(
        '/fuels/subsidized',
      );

      final data = response.data;
      if (data == null) {
        return [];
      }

      return data.cast<Map<String, dynamic>>();
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<List<Map<String, dynamic>>> getFuels() async {
    try {
      final response = await _apiClient.dio.get<List<dynamic>>('/fuels');

      final data = response.data;
      if (data == null) {
        return [];
      }

      return data.cast<Map<String, dynamic>>();
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<CashierTransactionPage> getCashierTransactions({
    String? query,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? cursor,
    int limit = 20,
    bool includeSummary = true,
  }) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/cashier/transactions',
        queryParameters: {
          if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
          if (dateFrom != null) 'date_from': dateFrom.toUtc().toIso8601String(),
          if (dateTo != null) 'date_to': dateTo.toUtc().toIso8601String(),
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
          'limit': limit,
          'include_summary': includeSummary,
        },
      );

      final data = response.data;
      if (data == null) {
        throw Exception('Backend tidak mengembalikan riwayat transaksi.');
      }

      return CashierTransactionPage.fromJson(data);
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<CashierRecentScanPage> getRecentScans({
    DateTime? dateFrom,
    DateTime? dateTo,
    String? cursor,
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/cashier/recent-scans',
        queryParameters: {
          if (dateFrom != null) 'date_from': dateFrom.toUtc().toIso8601String(),
          if (dateTo != null) 'date_to': dateTo.toUtc().toIso8601String(),
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
          'limit': limit,
        },
      );

      final data = response.data;
      if (data == null) {
        throw Exception('Backend tidak mengembalikan recent scans.');
      }

      return CashierRecentScanPage.fromJson(data);
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<CashierPerformanceSnapshot> getCashierPerformance({
    DateTime? dateFrom,
    DateTime? dateTo,
    int recentLimit = 5,
  }) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/cashier/performance',
        queryParameters: {
          if (dateFrom != null) 'date_from': dateFrom.toUtc().toIso8601String(),
          if (dateTo != null) 'date_to': dateTo.toUtc().toIso8601String(),
          'recent_limit': recentLimit,
        },
      );

      final data = response.data;
      if (data == null) {
        throw Exception('Backend tidak mengembalikan statistik kasir.');
      }

      return CashierPerformanceSnapshot.fromJson(data);
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<Map<String, dynamic>> executeFuelPurchase({
    required String nik,
    required String plateNumber,
    required String fuelTypeId,
    required double liters,
    required int totalAmount,
    required String paymentMethod,
    int? amountPaid,
    String? pin,
  }) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/wallet/fuel-purchase',
        data: {
          'nik': nik,
          'plate_number': plateNumber,
          'fuel_type_id': fuelTypeId,
          'liters': liters,
          'total_amount': totalAmount,
          'payment_method': paymentMethod,
          ...?amountPaid != null ? {'amount_paid': amountPaid} : null,
          ...?pin != null ? {'pin': pin} : null,
        },
      );

      final data = response.data;
      if (data == null) {
        throw Exception('Gagal melakukan transaksi pembelian BBM.');
      }
      return data;
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<Map<String, dynamic>> createQrisFuelPurchase({
    required String nik,
    required String plateNumber,
    required String fuelTypeId,
    required double liters,
    required int totalAmount,
  }) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/wallet/fuel-purchase/qris',
        data: {
          'nik': nik,
          'plate_number': plateNumber,
          'fuel_type_id': fuelTypeId,
          'liters': liters,
          'total_amount': totalAmount,
        },
      );

      final data = response.data;
      if (data == null) {
        throw Exception('Gagal membuat pembayaran QRIS.');
      }
      return data;
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<Map<String, dynamic>> pollQrisFuelPurchaseStatus(
    String transactionId,
  ) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/wallet/fuel-purchase/qris/$transactionId',
      );

      final data = response.data;
      if (data == null) {
        throw Exception('Gagal membaca status pembayaran QRIS.');
      }
      return data;
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<Map<String, dynamic>> createXenditFuelPurchase({
    required String nik,
    required String plateNumber,
    required String fuelTypeId,
    required double liters,
    required int totalAmount,
  }) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/wallet/fuel-purchase/xendit',
        data: {
          'nik': nik,
          'plate_number': plateNumber,
          'fuel_type_id': fuelTypeId,
          'liters': liters,
          'total_amount': totalAmount,
        },
      );

      final data = response.data;
      if (data == null) {
        throw Exception('Gagal membuat pembayaran Xendit.');
      }
      return data;
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<Map<String, dynamic>> pollXenditFuelPurchaseStatus(
    String transactionId,
  ) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/wallet/fuel-purchase/xendit/$transactionId',
      );

      final data = response.data;
      if (data == null) {
        throw Exception('Gagal membaca status pembayaran Xendit.');
      }
      return data;
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  String _extractErrorMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final detail = data['detail'];
      if (detail is String && detail.trim().isNotEmpty) {
        return detail;
      }
    }

    return error.message ?? 'Terjadi kesalahan jaringan. Coba lagi.';
  }
}
