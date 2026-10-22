import 'package:landtrust_app/core/network/api_client.dart';

class ChatRepository {
  Future<List<dynamic>> fetchMyThreads() async {
    final res = await ApiClient.get('/member/chat/threads');
    final data = ApiClient.parseResponse(res);
    return data is List ? data : [];
  }

  Future<Map<String, dynamic>> startThread({
    required String subject,
    int? listingId,
    String? initialMessage,
  }) async {
    final res = await ApiClient.post('/member/chat/threads', body: {
      'subject': subject,
      'listingId': ?listingId,
      'initialMessage': ?initialMessage,
    });
    final data = ApiClient.parseResponse(res);
    return data is Map<String, dynamic> ? data : {};
  }

  Future<List<dynamic>> fetchMessages(int threadId) async {
    final res = await ApiClient.get('/member/chat/threads/$threadId/messages');
    final data = ApiClient.parseResponse(res);
    return data is List ? data : [];
  }

  Future<Map<String, dynamic>> sendMessage(int threadId, String text, {String? attachmentUrl}) async {
    final res = await ApiClient.post('/member/chat/threads/$threadId/messages', body: {
      'text': text,
      'attachmentUrl': ?attachmentUrl,
    });
    final data = ApiClient.parseResponse(res);
    return data is Map<String, dynamic> ? data : {};
  }

  // Admin Endpoints
  Future<List<dynamic>> fetchAdminThreads() async {
    final res = await ApiClient.get('/admin/chat/threads');
    final data = ApiClient.parseResponse(res);
    return data is List ? data : [];
  }

  Future<List<dynamic>> fetchAdminMessages(int threadId) async {
    final res = await ApiClient.get('/admin/chat/threads/$threadId/messages');
    final data = ApiClient.parseResponse(res);
    return data is List ? data : [];
  }

  Future<Map<String, dynamic>> adminReply(int threadId, String text) async {
    final res = await ApiClient.post('/admin/chat/threads/$threadId/reply', body: {
      'text': text,
    });
    final data = ApiClient.parseResponse(res);
    return data is Map<String, dynamic> ? data : {};
  }

  Future<void> updateThreadStatus(int threadId, String status) async {
    final res = await ApiClient.put('/admin/chat/threads/$threadId/status', body: {
      'status': status,
    });
    ApiClient.parseResponse(res);
  }
}
