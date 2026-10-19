import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _envApiUrl = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_envApiUrl.isNotEmpty) {
      return _envApiUrl;
    }
    if (kIsWeb) {
      // Local dev server runs on port 8086; Dokploy Nginx serves both web & /api on same origin
      if (Uri.base.port == 8086) {
        return 'http://localhost:8085/api';
      }
      return '${Uri.base.origin}/api';
    }
    // Android / Waydroid local bridge IP
    return 'http://192.168.240.1:8085/api';
  }

  static String? token;
  static Map<String, dynamic>? currentUser;

  static Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };
    if (token != null && token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // ==================== PUBLIC ENDPOINTS ====================

  static Future<Map<String, dynamic>> getPublicConfig() async {
    final res = await http.get(Uri.parse('$baseUrl/public/config'), headers: _headers);
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getPublicStats() async {
    final res = await http.get(Uri.parse('$baseUrl/public/stats'), headers: _headers);
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getPublicListings({
    String? upazila,
    String? landType,
    String? maxBudget,
  }) async {
    final query = <String, String>{};
    if (upazila != null && upazila.isNotEmpty) query['upazila'] = upazila;
    if (landType != null && landType.isNotEmpty) query['landType'] = landType;
    if (maxBudget != null && maxBudget.isNotEmpty) query['maxBudget'] = maxBudget;

    final uri = Uri.parse('$baseUrl/public/listings').replace(
      queryParameters: query.isEmpty ? null : query,
    );
    final res = await http.get(uri, headers: _headers);
    return jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>;
  }

  static Future<List<dynamic>> getPublicRequirements({String? upazila, String? landType}) async {
    final query = <String, String>{};
    if (upazila != null && upazila.isNotEmpty) query['upazila'] = upazila;
    if (landType != null && landType.isNotEmpty) query['landType'] = landType;

    final uri = Uri.parse('$baseUrl/public/requirements').replace(
      queryParameters: query.isEmpty ? null : query,
    );
    final res = await http.get(uri, headers: _headers);
    return jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>;
  }

  // ==================== AUTH ENDPOINTS ====================

  static Future<Map<String, dynamic>> login(String phoneNumber, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers,
      body: jsonEncode({'phoneNumber': phoneNumber, 'password': password}),
    );
    final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    if (res.statusCode == 200) {
      token = data['token'] as String?;
      currentUser = data['user'] as Map<String, dynamic>?;
    } else {
      throw Exception(data['message'] ?? 'লগইন ব্যর্থ হয়েছে');
    }
    return data;
  }

  static Future<Map<String, dynamic>> register(Map<String, dynamic> payload) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers,
      body: jsonEncode(payload),
    );
    final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    if (res.statusCode == 200) {
      token = data['token'] as String?;
      currentUser = data['user'] as Map<String, dynamic>?;
    } else {
      throw Exception(data['message'] ?? 'নিবন্ধন ব্যর্থ হয়েছে');
    }
    return data;
  }

  static Future<Map<String, dynamic>> refreshMe() async {
    final res = await http.get(Uri.parse('$baseUrl/user/me'), headers: _headers);
    if (res.statusCode == 200) {
      currentUser = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      return currentUser!;
    }
    throw Exception('সেশন শেষ হয়েছে');
  }

  static void logout() {
    token = null;
    currentUser = null;
  }

  // ==================== MEMBER PORTAL ENDPOINTS ====================

  static Future<List<dynamic>> getMyListings() async {
    final res = await http.get(Uri.parse('$baseUrl/portal/my-listings'), headers: _headers);
    return jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> createListing(Map<String, dynamic> payload) async {
    final res = await http.post(
      Uri.parse('$baseUrl/portal/listings'),
      headers: _headers,
      body: jsonEncode(payload),
    );
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getMyRequirements() async {
    final res = await http.get(Uri.parse('$baseUrl/portal/my-requirements'), headers: _headers);
    return jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> createRequirement(Map<String, dynamic> payload) async {
    final res = await http.post(
      Uri.parse('$baseUrl/portal/requirements'),
      headers: _headers,
      body: jsonEncode(payload),
    );
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> createInquiry(Map<String, dynamic> payload) async {
    final res = await http.post(
      Uri.parse('$baseUrl/portal/inquiries'),
      headers: _headers,
      body: jsonEncode(payload),
    );
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getMyInquiries() async {
    final res = await http.get(Uri.parse('$baseUrl/portal/my-inquiries'), headers: _headers);
    return jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> getOfficerDashboard() async {
    final res = await http.get(Uri.parse('$baseUrl/portal/officer-dashboard'), headers: _headers);
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getMyProposals() async {
    final res = await http.get(Uri.parse('$baseUrl/portal/my-proposals'), headers: _headers);
    return jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> createProposal(Map<String, dynamic> payload) async {
    final res = await http.post(
      Uri.parse('$baseUrl/portal/proposals'),
      headers: _headers,
      body: jsonEncode(payload),
    );
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> acceptCounterOffer(int id) async {
    final res = await http.put(
      Uri.parse('$baseUrl/portal/proposals/$id/accept-counter'),
      headers: _headers,
    );
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  // ==================== ADMIN ENDPOINTS ====================

  static Future<Map<String, dynamic>> getAdminDashboard() async {
    final res = await http.get(Uri.parse('$baseUrl/admin/dashboard'), headers: _headers);
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> updateAdminSettings(Map<String, dynamic> payload) async {
    final res = await http.put(
      Uri.parse('$baseUrl/admin/settings'),
      headers: _headers,
      body: jsonEncode(payload),
    );
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getAdminPaymentMethods() async {
    final res = await http.get(Uri.parse('$baseUrl/admin/payment-methods'), headers: _headers);
    return jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> addPaymentMethod(Map<String, dynamic> payload) async {
    final res = await http.post(
      Uri.parse('$baseUrl/admin/payment-methods'),
      headers: _headers,
      body: jsonEncode(payload),
    );
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  static Future<void> deletePaymentMethod(int id) async {
    await http.delete(Uri.parse('$baseUrl/admin/payment-methods/$id'), headers: _headers);
  }

  static Future<List<dynamic>> getAdminUsers({String? role}) async {
    final uri = role == null || role.isEmpty
        ? Uri.parse('$baseUrl/admin/users')
        : Uri.parse('$baseUrl/admin/users?role=$role');
    final res = await http.get(uri, headers: _headers);
    return jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> updateUserStatus(int id, String status, String note) async {
    final res = await http.put(
      Uri.parse('$baseUrl/admin/users/$id/status'),
      headers: _headers,
      body: jsonEncode({'accountStatus': status, 'adminNote': note}),
    );
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getAdminListings() async {
    final res = await http.get(Uri.parse('$baseUrl/admin/listings'), headers: _headers);
    return jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> updateListingStatus(
    int id, {
    String? listingStatus,
    String? verificationStatus,
    String? adminRemark,
  }) async {
    final body = <String, String>{};
    if (listingStatus != null) body['listingStatus'] = listingStatus;
    if (verificationStatus != null) body['verificationStatus'] = verificationStatus;
    if (adminRemark != null) body['adminRemark'] = adminRemark;

    final res = await http.put(
      Uri.parse('$baseUrl/admin/listings/$id/status'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getAdminRequirements() async {
    final res = await http.get(Uri.parse('$baseUrl/admin/requirements'), headers: _headers);
    return jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> updateRequirementStatus(int id, String status, String remark) async {
    final res = await http.put(
      Uri.parse('$baseUrl/admin/requirements/$id/status'),
      headers: _headers,
      body: jsonEncode({'status': status, 'adminRemark': remark}),
    );
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getAdminCommissions() async {
    final res = await http.get(Uri.parse('$baseUrl/admin/commissions'), headers: _headers);
    return jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> awardCommission(Map<String, dynamic> payload) async {
    final res = await http.post(
      Uri.parse('$baseUrl/admin/commissions/award'),
      headers: _headers,
      body: jsonEncode(payload),
    );
    final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    if (res.statusCode != 200) {
      throw Exception(data['message'] ?? 'কমিশন যোগ করতে সমস্যা হয়েছে');
    }
    return data;
  }

  static Future<Map<String, dynamic>> payCommission(int id, String paymentReference) async {
    final res = await http.put(
      Uri.parse('$baseUrl/admin/commissions/$id/pay'),
      headers: _headers,
      body: jsonEncode({'paymentReference': paymentReference}),
    );
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getAdminProposals() async {
    final res = await http.get(Uri.parse('$baseUrl/admin/proposals'), headers: _headers);
    return jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> updateAdminProposal(int id, Map<String, dynamic> payload) async {
    final res = await http.put(
      Uri.parse('$baseUrl/admin/proposals/$id'),
      headers: _headers,
      body: jsonEncode(payload),
    );
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getAdminTransactions() async {
    final res = await http.get(Uri.parse('$baseUrl/admin/transactions'), headers: _headers);
    return jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> createAdminTransaction(Map<String, dynamic> payload) async {
    final res = await http.post(
      Uri.parse('$baseUrl/admin/transactions'),
      headers: _headers,
      body: jsonEncode(payload),
    );
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }
}
