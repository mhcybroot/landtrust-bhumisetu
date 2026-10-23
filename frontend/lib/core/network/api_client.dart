import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../session/session_manager.dart';

class ApiClient {
  static const String _envApiUrl = String.fromEnvironment('API_URL', defaultValue: '');
  static const Duration _timeout = Duration(seconds: 12);

  static String get baseUrl {
    if (_envApiUrl.isNotEmpty) {
      return _envApiUrl;
    }
    if (kIsWeb) {
      if (Uri.base.port == 8086) {
        return 'http://localhost:8085/api';
      }
      return '${Uri.base.origin}/api';
    }
    return 'http://45.132.241.64:9999/api';
  }

  static String get publicWebOrigin {
    if (kIsWeb && Uri.base.port != 8086) {
      return Uri.base.origin;
    }
    return 'http://45.132.241.64:9999';
  }

  static Map<String, String> get headers {
    final map = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };
    final token = SessionManager.instance.token;
    if (token != null && token.isNotEmpty) {
      map['Authorization'] = 'Bearer $token';
    }
    return map;
  }

  static Future<http.Response> get(String path) {
    final uri = Uri.parse('$baseUrl$path');
    return http.get(uri, headers: headers).timeout(_timeout, onTimeout: () {
      throw Exception('সার্ভার সাড়া দিতে বিলম্ব হচ্ছে। ইন্টারনেট সংযোগ চেক করে পুনরায় চেষ্টা করুন।');
    });
  }

  static Future<http.Response> post(String path, {Object? body}) {
    final uri = Uri.parse('$baseUrl$path');
    final encoded = body is String ? body : jsonEncode(body);
    return http.post(uri, headers: headers, body: encoded).timeout(_timeout, onTimeout: () {
      throw Exception('সার্ভার সাড়া দিতে বিলম্ব হচ্ছে। ইন্টারনেট সংযোগ চেক করে পুনরায় চেষ্টা করুন।');
    });
  }

  static Future<http.Response> put(String path, {Object? body}) {
    final uri = Uri.parse('$baseUrl$path');
    final encoded = body is String ? body : jsonEncode(body);
    return http.put(uri, headers: headers, body: encoded).timeout(_timeout, onTimeout: () {
      throw Exception('সার্ভার সাড়া দিতে বিলম্ব হচ্ছে। ইন্টারনেট সংযোগ চেক করে পুনরায় চেষ্টা করুন।');
    });
  }

  static Future<http.Response> delete(String path) {
    final uri = Uri.parse('$baseUrl$path');
    return http.delete(uri, headers: headers).timeout(_timeout, onTimeout: () {
      throw Exception('সার্ভার সাড়া দিতে বিলম্ব হচ্ছে। ইন্টারনেট সংযোগ চেক করে পুনরায় চেষ্টা করুন।');
    });
  }

  static dynamic parseResponse(http.Response res) {
    final utf8Body = utf8.decode(res.bodyBytes);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (utf8Body.isEmpty) return {};
      try {
        return jsonDecode(utf8Body);
      } catch (_) {
        return utf8Body;
      }
    }
    String message = 'অনুরোধ ব্যর্থ হয়েছে (${res.statusCode})';
    try {
      final map = jsonDecode(utf8Body);
      if (map is Map && map['error'] != null) {
        message = map['error'].toString();
      } else if (map is Map && map['message'] != null) {
        message = map['message'].toString();
      }
    } catch (_) {
      if (utf8Body.isNotEmpty) message = utf8Body;
    }
    throw Exception(message);
  }
}
