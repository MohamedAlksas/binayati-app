import 'package:dio/dio.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _api = ApiClient();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _api.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      final data = response.data as Map<String, dynamic>;
      await _api.setToken(data['token']);
      return data;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Login failed');
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password,
      {String phone = ''}) async {
    try {
      final response = await _api.post('/auth/register', data: {
        'fullName': name,
        'email': email,
        'password': password,
        'phoneNumber': phone,
      });
      final data = response.data as Map<String, dynamic>;
      await _api.setToken(data['token']);
      return data;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Registration failed');
    }
  }

  Future<void> logout() async {
    await _api.clearToken();
  }

  Future<Map<String, dynamic>?> getStoredUser() async {
    try {
      final response = await _api.get('/auth/profile');
      return response.data as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }
}
