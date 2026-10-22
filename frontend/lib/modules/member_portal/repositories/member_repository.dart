import 'package:landtrust_app/core/network/api_client.dart';
import 'package:landtrust_app/core/session/session_manager.dart';

class MemberRepository {
  Future<Map<String, dynamic>> refreshProfile() async {
    final res = await ApiClient.get('/member/me');
    final data = ApiClient.parseResponse(res) as Map<String, dynamic>;
    if (data['user'] != null) {
      await SessionManager.instance.saveSession(
        SessionManager.instance.token ?? '',
        data['user'] as Map<String, dynamic>,
      );
    }
    return data;
  }

  Future<Map<String, dynamic>> fetchNotifications() async {
    final res = await ApiClient.get('/member/notifications');
    final data = ApiClient.parseResponse(res);
    return data is Map<String, dynamic> ? data : {'notifications': [], 'unreadCount': 0};
  }

  Future<void> markNotificationRead(int id) async {
    final res = await ApiClient.post('/member/notifications/$id/read');
    ApiClient.parseResponse(res);
  }

  Future<void> markAllNotificationsRead() async {
    final res = await ApiClient.put('/member/notifications/read-all');
    ApiClient.parseResponse(res);
  }

  Future<Map<String, dynamic>> fetchOfficerDashboard() async {
    final res = await ApiClient.get('/member/officer/dashboard');
    final data = ApiClient.parseResponse(res);
    return data is Map<String, dynamic> ? data : {};
  }

  Future<List<dynamic>> fetchSellerListings() async {
    final res = await ApiClient.get('/member/seller/listings');
    final data = ApiClient.parseResponse(res);
    return data is List ? data : [];
  }

  Future<Map<String, dynamic>> createListing(Map<String, dynamic> payload) async {
    final res = await ApiClient.post('/member/seller/listings', body: payload);
    return ApiClient.parseResponse(res) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateListing(int id, Map<String, dynamic> payload) async {
    final res = await ApiClient.put('/member/seller/listings/$id', body: payload);
    return ApiClient.parseResponse(res) as Map<String, dynamic>;
  }

  Future<List<dynamic>> fetchBuyerRequirements() async {
    final res = await ApiClient.get('/member/buyer/requirements');
    final data = ApiClient.parseResponse(res);
    return data is List ? data : [];
  }

  Future<Map<String, dynamic>> createRequirement(Map<String, dynamic> payload) async {
    final res = await ApiClient.post('/member/buyer/requirements', body: payload);
    return ApiClient.parseResponse(res) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateRequirement(int id, Map<String, dynamic> payload) async {
    final res = await ApiClient.put('/member/buyer/requirements/$id', body: payload);
    return ApiClient.parseResponse(res) as Map<String, dynamic>;
  }

  Future<List<dynamic>> fetchBuyerInquiries() async {
    final res = await ApiClient.get('/member/buyer/inquiries');
    final data = ApiClient.parseResponse(res);
    return data is List ? data : [];
  }

  Future<List<dynamic>> fetchProposals() async {
    final res = await ApiClient.get('/member/proposals');
    final data = ApiClient.parseResponse(res);
    return data is List ? data : [];
  }

  Future<Map<String, dynamic>> respondProposal(int id, String action, {String? notes}) async {
    final res = await ApiClient.post('/member/proposals/$id/respond', body: {
      'action': action,
      if (notes != null) 'notes': notes,
    });
    return ApiClient.parseResponse(res) as Map<String, dynamic>;
  }

  Future<void> requestOfficerPayout(double amount, String method, String account) async {
    final res = await ApiClient.post('/member/officer/payout-request', body: {
      'amountBdt': amount,
      'paymentMethod': method,
      'accountNumber': account,
    });
    ApiClient.parseResponse(res);
  }

  Future<void> resubmitPayment(String method, String senderPhone, String trxId) async {
    final res = await ApiClient.post('/member/resubmit-payment', body: {
      'paymentMethod': method,
      'senderPhone': senderPhone,
      'transactionId': trxId,
    });
    final data = ApiClient.parseResponse(res);
    if (data is Map<String, dynamic> && data['user'] != null) {
      await SessionManager.instance.saveSession(
        SessionManager.instance.token ?? '',
        data['user'] as Map<String, dynamic>,
      );
    }
  }

  Future<void> updateProfile(String fullName, String district, String upazila, String address) async {
    final res = await ApiClient.put('/member/profile', body: {
      'fullName': fullName,
      'district': district,
      'upazila': upazila,
      'address': address,
    });
    final data = ApiClient.parseResponse(res);
    if (data is Map<String, dynamic> && data['user'] != null) {
      await SessionManager.instance.saveSession(
        SessionManager.instance.token ?? '',
        data['user'] as Map<String, dynamic>,
      );
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    final res = await ApiClient.put('/member/change-password', body: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
    ApiClient.parseResponse(res);
  }

  Future<void> deleteAccount() async {
    final res = await ApiClient.delete('/member/account');
    ApiClient.parseResponse(res);
    await SessionManager.instance.clearSession();
  }
}
