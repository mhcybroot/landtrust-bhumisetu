import 'package:landtrust_app/core/network/api_client.dart';

class AdminRepository {
  Future<Map<String, dynamic>> fetchDashboard() async {
    final res = await ApiClient.get('/admin/dashboard');
    final data = ApiClient.parseResponse(res);
    return data is Map<String, dynamic> ? data : {};
  }

  Future<List<dynamic>> fetchUsers() async {
    final res = await ApiClient.get('/admin/users');
    final data = ApiClient.parseResponse(res);
    return data is List ? data : [];
  }

  Future<void> verifyUserPayment(int userId, bool isApproved, String? note) async {
    await ApiClient.post('/admin/users/$userId/verify-payment', body: {
      'approved': isApproved,
      if (note != null) 'note': note,
    });
  }

  Future<void> resetUserPassword(int userId, String newPassword) async {
    await ApiClient.post('/admin/users/$userId/reset-password', body: {
      'newPassword': newPassword,
    });
  }

  Future<void> refundUserFee(int userId, String reason, String trxId) async {
    await ApiClient.post('/admin/users/$userId/refund', body: {
      'reason': reason,
      'refundTransactionId': trxId,
    });
  }

  Future<List<dynamic>> fetchListings() async {
    final res = await ApiClient.get('/admin/listings');
    final data = ApiClient.parseResponse(res);
    return data is List ? data : [];
  }

  Future<void> verifyListing(int listingId, String status, String? notes) async {
    await ApiClient.post('/admin/listings/$listingId/verify', body: {
      'status': status,
      if (notes != null) 'notes': notes,
    });
  }

  Future<void> approveListing(int listingId) async {
    await ApiClient.post('/admin/listings/$listingId/approve');
  }

  Future<List<dynamic>> fetchRequirements() async {
    final res = await ApiClient.get('/admin/requirements');
    final data = ApiClient.parseResponse(res);
    return data is List ? data : [];
  }

  Future<void> verifyRequirement(int reqId, bool isApproved) async {
    await ApiClient.post('/admin/requirements/$reqId/verify', body: {
      'approved': isApproved,
    });
  }

  Future<List<dynamic>> fetchInquiries() async {
    final res = await ApiClient.get('/admin/inquiries');
    final data = ApiClient.parseResponse(res);
    return data is List ? data : [];
  }

  Future<List<dynamic>> fetchCommissions() async {
    final res = await ApiClient.get('/admin/commissions');
    final data = ApiClient.parseResponse(res);
    return data is List ? data : [];
  }

  Future<void> awardCommission(Map<String, dynamic> payload) async {
    await ApiClient.post('/admin/commissions/award', body: payload);
  }

  Future<void> markCommissionPaid(int id, String paymentRef) async {
    await ApiClient.post('/admin/commissions/$id/pay', body: {
      'paymentReference': paymentRef,
    });
  }

  Future<List<dynamic>> fetchProposals() async {
    final res = await ApiClient.get('/admin/proposals');
    final data = ApiClient.parseResponse(res);
    return data is List ? data : [];
  }

  Future<void> respondProposal(int id, String action, {String? notes, double? agreedFee}) async {
    await ApiClient.post('/admin/proposals/$id/respond', body: {
      'action': action,
      if (notes != null) 'notes': notes,
      if (agreedFee != null) 'finalAgreedFeeBdt': agreedFee,
    });
  }

  Future<List<dynamic>> fetchTransactions() async {
    final res = await ApiClient.get('/admin/finance/transactions');
    final data = ApiClient.parseResponse(res);
    return data is List ? data : [];
  }

  Future<void> addExpense(Map<String, dynamic> payload) async {
    await ApiClient.post('/admin/finance/expenses', body: payload);
  }

  Future<List<dynamic>> fetchPaymentMethods() async {
    final res = await ApiClient.get('/admin/payment-methods');
    final data = ApiClient.parseResponse(res);
    return data is List ? data : [];
  }

  Future<void> createPaymentMethod(Map<String, dynamic> payload) async {
    final res = await ApiClient.post('/admin/payment-methods', body: payload);
    ApiClient.parseResponse(res);
  }

  Future<void> deletePaymentMethod(int id) async {
    final res = await ApiClient.delete('/admin/payment-methods/$id');
    ApiClient.parseResponse(res);
  }

  Future<List<dynamic>> fetchLocations() async {
    final res = await ApiClient.get('/admin/locations');
    final data = ApiClient.parseResponse(res);
    return data is List ? data : [];
  }

  Future<void> createLocation(Map<String, dynamic> payload) async {
    final res = await ApiClient.post('/admin/locations', body: payload);
    ApiClient.parseResponse(res);
  }

  Future<void> deleteLocation(int id) async {
    final res = await ApiClient.delete('/admin/locations/$id');
    ApiClient.parseResponse(res);
  }

  Future<void> updateSettings(Map<String, dynamic> payload) async {
    final res = await ApiClient.put('/admin/settings', body: payload);
    ApiClient.parseResponse(res);
  }

  Future<void> sendNotificationToUser(int userId, String title, String message) async {
    final res = await ApiClient.post('/admin/users/$userId/notify', body: {
      'title': title,
      'message': message,
    });
    ApiClient.parseResponse(res);
  }

  Future<void> broadcastNotification(String title, String message, {String? role}) async {
    final res = await ApiClient.post('/admin/notifications/broadcast', body: {
      'title': title,
      'message': message,
      if (role != null) 'role': role,
    });
    ApiClient.parseResponse(res);
  }
}
