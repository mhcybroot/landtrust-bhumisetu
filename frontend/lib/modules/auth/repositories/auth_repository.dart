import 'package:landtrust_app/core/network/api_client.dart';
import 'package:landtrust_app/core/session/session_manager.dart';

class AuthRepository {
  Future<Map<String, dynamic>> login(String phoneNumber, String password) async {
    final response = await ApiClient.post(
      '/auth/login',
      body: {'phoneNumber': phoneNumber, 'password': password},
    );
    final data = ApiClient.parseResponse(response) as Map<String, dynamic>;
    final token = data['token'] as String?;
    final user = data['user'] as Map<String, dynamic>?;
    if (token != null && user != null) {
      await SessionManager.instance.saveSession(token, user);
    }
    return data;
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> payload) async {
    final response = await ApiClient.post('/auth/register', body: payload);
    final data = ApiClient.parseResponse(response) as Map<String, dynamic>;
    final token = data['token'] as String?;
    final user = data['user'] as Map<String, dynamic>?;
    if (token != null && user != null) {
      await SessionManager.instance.saveSession(token, user);
    }
    return data;
  }

  Future<void> logout() async {
    await SessionManager.instance.clearSession();
  }
}
