import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _envApiUrl = String.fromEnvironment('API_BASE_URL');
  static const String _prefTokenKey = 'landtrust_jwt_token';
  static const String _prefUserKey = 'landtrust_current_user';
  static const Duration _timeout = Duration(seconds: 12);

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
    // Live Dokploy production server for Android / Waydroid
    return 'http://45.132.241.64:9999/api';
  }

  static String get publicWebOrigin {
    if (kIsWeb && Uri.base.port != 8086) {
      return Uri.base.origin;
    }
    return 'http://45.132.241.64:9999';
  }

  static Widget buildSmartImage(
    String? url, {
    double? height,
    double? width,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    bool enableZoom = false,
  }) {
    final fallback = Container(
      height: height,
      width: width,
      color: const Color(0xFFD8F3DC),
      child: const Center(
        child: Icon(Icons.landscape_rounded, size: 44, color: Color(0xFF1B5E20)),
      ),
    );
    Widget img = fallback;
    if (url != null && url.trim().isNotEmpty) {
      if (url.startsWith('data:image/')) {
        try {
          final commaIdx = url.indexOf(',');
          if (commaIdx != -1) {
            final bytes = base64Decode(url.substring(commaIdx + 1));
            img = Image.memory(
              bytes,
              height: height,
              width: width,
              fit: fit,
              errorBuilder: (_, _, _) => fallback,
            );
          }
        } catch (_) {
          img = fallback;
        }
      } else {
        img = Image.network(
          url,
          height: height,
          width: width,
          fit: fit,
          errorBuilder: (_, _, _) => fallback,
        );
      }
    }
    if (borderRadius != null) {
      img = ClipRRect(borderRadius: borderRadius, child: img);
    }
    if (enableZoom) {
      return InteractiveViewer(
        minScale: 0.8,
        maxScale: 4.5,
        child: img,
      );
    }
    return img;
  }

  static String? token;
  static Map<String, dynamic>? currentUser;

  static Future<void> restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString(_prefTokenKey);
      final savedUserJson = prefs.getString(_prefUserKey);
      if (savedToken != null && savedToken.isNotEmpty) {
        token = savedToken;
        if (savedUserJson != null && savedUserJson.isNotEmpty) {
          currentUser = jsonDecode(savedUserJson) as Map<String, dynamic>;
        }
        try {
          await refreshMe();
        } catch (_) {
          // If token expired or user deleted, clear session
          await logout();
        }
      }
    } catch (_) {}
  }

  static Future<void> _saveSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (token != null && token!.isNotEmpty) {
        await prefs.setString(_prefTokenKey, token!);
      }
      if (currentUser != null) {
        await prefs.setString(_prefUserKey, jsonEncode(currentUser));
      }
    } catch (_) {}
  }

  static Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };
    if (token != null && token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Safe timeout-aware HTTP helpers
  static Future<http.Response> _safeGet(Uri uri) {
    return http.get(uri, headers: _headers).timeout(_timeout, onTimeout: () {
      throw Exception('সার্ভার সাড়া দিতে বিলম্ব হচ্ছে। ইন্টারনেট সংযোগ চেক করে পুনরায় চেষ্টা করুন।');
    });
  }

  static Future<http.Response> _safePost(Uri uri, {Object? body}) {
    return http.post(uri, headers: _headers, body: body).timeout(_timeout, onTimeout: () {
      throw Exception('সার্ভার সাড়া দিতে বিলম্ব হচ্ছে। ইন্টারনেট সংযোগ চেক করে পুনরায় চেষ্টা করুন।');
    });
  }

  static Future<http.Response> _safePut(Uri uri, {Object? body}) {
    return http.put(uri, headers: _headers, body: body).timeout(_timeout, onTimeout: () {
      throw Exception('সার্ভার সাড়া দিতে বিলম্ব হচ্ছে। ইন্টারনেট সংযোগ চেক করে পুনরায় চেষ্টা করুন।');
    });
  }

  static Future<http.Response> _safeDelete(Uri uri) {
    return http.delete(uri, headers: _headers).timeout(_timeout, onTimeout: () {
      throw Exception('সার্ভার সাড়া দিতে বিলম্ব হচ্ছে। ইন্টারনেট সংযোগ চেক করে পুনরায় চেষ্টা করুন।');
    });
  }

  // ==================== PUBLIC ENDPOINTS ====================

  static Future<Map<String, dynamic>> getPublicConfig() async {
    final res = await _safeGet(Uri.parse('$baseUrl/public/config'));
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getPublicStats() async {
    final res = await _safeGet(Uri.parse('$baseUrl/public/stats'));
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getPublicListings({
    String? district,
    String? upazila,
    String? landType,
    String? maxBudget,
    String? verificationStatus,
    String? minArea,
    String? maxArea,
    String? keyword,
  }) async {
    final query = <String, String>{};
    if (district != null && district.isNotEmpty) query['district'] = district;
    if (upazila != null && upazila.isNotEmpty) query['upazila'] = upazila;
    if (landType != null && landType.isNotEmpty) query['landType'] = landType;
    if (maxBudget != null && maxBudget.isNotEmpty) query['maxBudget'] = maxBudget;
    if (verificationStatus != null && verificationStatus.isNotEmpty) {
      query['verificationStatus'] = verificationStatus;
    }
    if (minArea != null && minArea.isNotEmpty) query['minArea'] = minArea;
    if (maxArea != null && maxArea.isNotEmpty) query['maxArea'] = maxArea;
    if (keyword != null && keyword.isNotEmpty) query['keyword'] = keyword;

    final uri = Uri.parse('$baseUrl/public/listings').replace(
      queryParameters: query.isEmpty ? null : query,
    );
    final res = await _safeGet(uri);
    return jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>;
  }

  static Future<List<dynamic>> getPublicRequirements({String? upazila, String? landType}) async {
    final query = <String, String>{};
    if (upazila != null && upazila.isNotEmpty) query['upazila'] = upazila;
    if (landType != null && landType.isNotEmpty) query['landType'] = landType;

    final uri = Uri.parse('$baseUrl/public/requirements').replace(
      queryParameters: query.isEmpty ? null : query,
    );
    final res = await _safeGet(uri);
    return jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>;
  }

  // ==================== AUTH ENDPOINTS ====================

  static Future<Map<String, dynamic>> login(String phoneNumber, String password) async {
    final res = await _safePost(
      Uri.parse('$baseUrl/auth/login'),
      body: jsonEncode({'phoneNumber': phoneNumber, 'password': password}),
    );
    final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    if (res.statusCode == 200) {
      token = data['token'] as String?;
      currentUser = data['user'] as Map<String, dynamic>?;
      await _saveSession();
    } else {
      throw Exception(data['message'] ?? 'লগইন ব্যর্থ হয়েছে');
    }
    return data;
  }

  static Future<Map<String, dynamic>> register(Map<String, dynamic> payload) async {
    final res = await _safePost(
      Uri.parse('$baseUrl/auth/register'),
      body: jsonEncode(payload),
    );
    final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    if (res.statusCode == 200) {
      token = data['token'] as String?;
      currentUser = data['user'] as Map<String, dynamic>?;
      await _saveSession();
    } else {
      throw Exception(data['message'] ?? 'নিবন্ধন ব্যর্থ হয়েছে');
    }
    return data;
  }

  static Future<Map<String, dynamic>> refreshMe() async {
    final res = await _safeGet(Uri.parse('$baseUrl/user/me'));
    if (res.statusCode == 200) {
      currentUser = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      await _saveSession();
      return currentUser!;
    }
    throw Exception('সেশন শেষ হয়েছে');
  }

  static Future<void> logout() async {
    token = null;
    currentUser = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefTokenKey);
      await prefs.remove(_prefUserKey);
    } catch (_) {}
  }

  // ==================== PROFILE, PASSWORD, NOTIFICATIONS & PAYMENT RESUBMIT ====================

  static Future<Map<String, dynamic>> updateMyProfile(Map<String, String> payload) async {
    final res = await _safePut(
      Uri.parse('$baseUrl/portal/profile'),
      body: jsonEncode(payload),
    );
    final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    if (res.statusCode == 200) {
      currentUser = data['user'] as Map<String, dynamic>?;
      await _saveSession();
      return data;
    }
    throw Exception(data['message'] ?? 'প্রোফাইল আপডেট ব্যর্থ হয়েছে');
  }

  static Future<Map<String, dynamic>> changeMyPassword(Map<String, String> payload) async {
    final res = await _safePut(
      Uri.parse('$baseUrl/portal/change-password'),
      body: jsonEncode(payload),
    );
    final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    if (res.statusCode == 200) {
      return data;
    }
    throw Exception(data['message'] ?? 'পাসওয়ার্ড পরিবর্তন ব্যর্থ হয়েছে');
  }

  static Future<Map<String, dynamic>> getMyNotifications() async {
    final res = await _safeGet(Uri.parse('$baseUrl/portal/notifications'));
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  static Future<void> markNotificationsRead() async {
    await _safePut(Uri.parse('$baseUrl/portal/notifications/mark-read'));
  }

  static Future<Map<String, dynamic>> resubmitPayment(Map<String, String> payload) async {
    final res = await _safePut(
      Uri.parse('$baseUrl/portal/resubmit-payment'),
      body: jsonEncode(payload),
    );
    final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    if (res.statusCode == 200) {
      currentUser = data['user'] as Map<String, dynamic>?;
      await _saveSession();
      return data;
    }
    throw Exception(data['message'] ?? 'পেমেন্ট পুনরায় জমা দিতে সমস্যা হয়েছে');
  }

  // ==================== MARKETING OFFICER ENDPOINTS ====================

  static Future<Map<String, dynamic>> getOfficerDashboard() async {
    final res = await _safeGet(Uri.parse('$baseUrl/portal/officer-dashboard'));
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> requestOfficerPayout(Map<String, String> payload) async {
    final res = await _safePost(
      Uri.parse('$baseUrl/portal/officer-payout-request'),
      body: jsonEncode(payload),
    );
    final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    if (res.statusCode == 200) {
      return data;
    }
    throw Exception(data['message'] ?? 'উত্তোলনের অনুরোধ ব্যর্থ হয়েছে');
  }

  // ==================== SELLER & BUYER LISTINGS, REQUIREMENTS & INQUIRIES ====================

  static Future<List<dynamic>> getMyListings() async {
    final res = await _safeGet(Uri.parse('$baseUrl/portal/my-listings'));
    return jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> createListing(Map<String, dynamic> payload) async {
    final res = await _safePost(
      Uri.parse('$baseUrl/portal/listings'),
      body: jsonEncode(payload),
    );
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> updateMyListing(int id, Map<String, dynamic> payload) async {
    final res = await _safePut(
      Uri.parse('$baseUrl/portal/listings/$id'),
      body: jsonEncode(payload),
    );
    final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    if (res.statusCode == 200) {
      return data;
    }
    throw Exception(data['message'] ?? 'বিজ্ঞাপন আপডেট ব্যর্থ হয়েছে');
  }

  static Future<Map<String, dynamic>> closeListing(int id) async {
    final res = await _safePut(Uri.parse('$baseUrl/portal/listings/$id/close'));
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getMyRequirements() async {
    final res = await _safeGet(Uri.parse('$baseUrl/portal/my-requirements'));
    return jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> createRequirement(Map<String, dynamic> payload) async {
    final res = await _safePost(
      Uri.parse('$baseUrl/portal/requirements'),
      body: jsonEncode(payload),
    );
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> updateMyRequirement(int id, Map<String, dynamic> payload) async {
    final res = await _safePut(
      Uri.parse('$baseUrl/portal/requirements/$id'),
      body: jsonEncode(payload),
    );
    final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    if (res.statusCode == 200) {
      return data;
    }
    throw Exception(data['message'] ?? 'চাহিদা আপডেট ব্যর্থ হয়েছে');
  }

  static Future<Map<String, dynamic>> fulfillMyRequirement(int id) async {
    final res = await _safePut(Uri.parse('$baseUrl/portal/requirements/$id/fulfill'));
    final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    if (res.statusCode == 200) {
      return data;
    }
    throw Exception(data['message'] ?? 'চাহিদা পূরণ আপডেট ব্যর্থ হয়েছে');
  }

  static Future<Map<String, dynamic>> submitSellerOfferForRequirement(int id, Map<String, dynamic> payload) async {
    final res = await _safePost(
      Uri.parse('$baseUrl/portal/requirements/$id/seller-offer'),
      body: jsonEncode(payload),
    );
    final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    if (res.statusCode == 200) {
      return data;
    }
    throw Exception(data['message'] ?? 'প্রস্তাব পাঠানো ব্যর্থ হয়েছে');
  }

  static Future<List<dynamic>> getMyInquiries() async {
    final res = await _safeGet(Uri.parse('$baseUrl/portal/my-inquiries'));
    return jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> createInquiry(Map<String, dynamic> payload) async {
    final res = await _safePost(
      Uri.parse('$baseUrl/portal/inquiries'),
      body: jsonEncode(payload),
    );
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getMyProposals() async {
    final res = await _safeGet(Uri.parse('$baseUrl/portal/my-proposals'));
    return jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> createProposal(Map<String, dynamic> payload) async {
    final res = await _safePost(
      Uri.parse('$baseUrl/portal/proposals'),
      body: jsonEncode(payload),
    );
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> acceptCounterOffer(int id) async {
    final res = await _safePut(
      Uri.parse('$baseUrl/portal/proposals/$id/accept-counter'),
    );
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  // ==================== ADMIN ENDPOINTS ====================

  static Future<Map<String, dynamic>> getAdminDashboard() async {
    final res = await _safeGet(Uri.parse('$baseUrl/admin/dashboard'));
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> updateAdminSettings(Map<String, dynamic> payload) async {
    final res = await _safePut(
      Uri.parse('$baseUrl/admin/settings'),
      body: jsonEncode(payload),
    );
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getAdminPaymentMethods() async {
    final res = await _safeGet(Uri.parse('$baseUrl/admin/payment-methods'));
    return jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> addPaymentMethod(Map<String, dynamic> payload) async {
    final res = await _safePost(
      Uri.parse('$baseUrl/admin/payment-methods'),
      body: jsonEncode(payload),
    );
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  static Future<void> deletePaymentMethod(int id) async {
    await _safeDelete(Uri.parse('$baseUrl/admin/payment-methods/$id'));
  }

  static Future<List<dynamic>> getAdminLocations() async {
    final res = await _safeGet(Uri.parse('$baseUrl/admin/locations'));
    return jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> addAdminLocation(Map<String, dynamic> payload) async {
    final res = await _safePost(
      Uri.parse('$baseUrl/admin/locations'),
      body: jsonEncode(payload),
    );
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  static Future<void> deleteAdminLocation(int id) async {
    await _safeDelete(Uri.parse('$baseUrl/admin/locations/$id'));
  }

  static Future<List<dynamic>> getAdminUsers({String? role}) async {
    final uri = role == null || role.isEmpty
        ? Uri.parse('$baseUrl/admin/users')
        : Uri.parse('$baseUrl/admin/users?role=$role');
    final res = await _safeGet(uri);
    return jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> updateUserStatus(int id, String status, String note) async {
    final res = await _safePut(
      Uri.parse('$baseUrl/admin/users/$id/status'),
      body: jsonEncode({'accountStatus': status, 'adminNote': note}),
    );
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> adminResetUserPassword(int id, String newPassword) async {
    final res = await _safePut(
      Uri.parse('$baseUrl/admin/users/$id/reset-password'),
      body: jsonEncode({'newPassword': newPassword}),
    );
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> adminRefundUserFee(int id, Map<String, String> payload) async {
    final res = await _safePost(
      Uri.parse('$baseUrl/admin/users/$id/refund'),
      body: jsonEncode(payload),
    );
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getAdminListings() async {
    final res = await _safeGet(Uri.parse('$baseUrl/admin/listings'));
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

    final res = await _safePut(
      Uri.parse('$baseUrl/admin/listings/$id/status'),
      body: jsonEncode(body),
    );
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getAdminRequirements() async {
    final res = await _safeGet(Uri.parse('$baseUrl/admin/requirements'));
    return jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> updateRequirementStatus(int id, String status, String remark) async {
    final res = await _safePut(
      Uri.parse('$baseUrl/admin/requirements/$id/status'),
      body: jsonEncode({'status': status, 'adminRemark': remark}),
    );
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getAdminInquiries() async {
    final res = await _safeGet(Uri.parse('$baseUrl/admin/inquiries'));
    return jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> updateAdminInquiryStatus(int id, String status, String note) async {
    final res = await _safePut(
      Uri.parse('$baseUrl/admin/inquiries/$id/status'),
      body: jsonEncode({'status': status, 'adminNote': note}),
    );
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getAdminCommissions() async {
    final res = await _safeGet(Uri.parse('$baseUrl/admin/commissions'));
    return jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> awardCommission(Map<String, dynamic> payload) async {
    final res = await _safePost(
      Uri.parse('$baseUrl/admin/commissions/award'),
      body: jsonEncode(payload),
    );
    final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    if (res.statusCode != 200) {
      throw Exception(data['message'] ?? 'কমিশন যোগ করতে সমস্যা হয়েছে');
    }
    return data;
  }

  static Future<Map<String, dynamic>> payCommission(int id, String paymentReference) async {
    final res = await _safePut(
      Uri.parse('$baseUrl/admin/commissions/$id/pay'),
      body: jsonEncode({'paymentReference': paymentReference}),
    );
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getAdminProposals() async {
    final res = await _safeGet(Uri.parse('$baseUrl/admin/proposals'));
    return jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> updateAdminProposal(int id, Map<String, dynamic> payload) async {
    final res = await _safePut(
      Uri.parse('$baseUrl/admin/proposals/$id'),
      body: jsonEncode(payload),
    );
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getAdminTransactions() async {
    final res = await _safeGet(Uri.parse('$baseUrl/admin/transactions'));
    return jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> createAdminTransaction(Map<String, dynamic> payload) async {
    final res = await _safePost(
      Uri.parse('$baseUrl/admin/transactions'),
      body: jsonEncode(payload),
    );
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }
}
