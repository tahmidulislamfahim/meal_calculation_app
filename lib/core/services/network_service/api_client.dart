import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:meal_calculation_app/core/services/local_service/preference_helper.dart';

class ApiClient extends GetxService {
  Future<Map<String, String>> _getHeaders() async {
    final token = await PreferenceHelper.getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<dynamic> get(String url) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);
      return _handleResponse(response);
    } catch (e) {
      _showErrorSnackbar('Connection Error', e.toString());
      rethrow;
    }
  }

  Future<dynamic> post(String url, Map<String, dynamic> body) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      _showErrorSnackbar('Connection Error', e.toString());
      rethrow;
    }
  }

  Future<dynamic> put(String url, Map<String, dynamic> body) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      _showErrorSnackbar('Connection Error', e.toString());
      rethrow;
    }
  }

  Future<dynamic> delete(String url) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      _showErrorSnackbar('Connection Error', e.toString());
      rethrow;
    }
  }

  dynamic _handleResponse(http.Response response) {
    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      decoded = response.body;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    } else if (response.statusCode == 401) {
      PreferenceHelper.clearSession();
      final currentRoute = Get.currentRoute;
      if (currentRoute != '/login' && currentRoute != '/splash') {
        Get.offAllNamed('/login');
        _showErrorSnackbar('Unauthorized', 'Session expired. Please login again.');
      }
      throw Exception('Unauthorized');
    } else {
      String msg = 'An unexpected error occurred';
      if (decoded is Map && decoded.containsKey('detail')) {
        msg = decoded['detail'].toString();
      }
      _showErrorSnackbar('Error (${response.statusCode})', msg);
      throw Exception(msg);
    }
  }

  void _showErrorSnackbar(String title, String message) {
    final route = Get.currentRoute;
    if (route == '/login' || route == '/splash') return;
    if (Get.isSnackbarOpen) return;
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }
}
