import 'package:flutter/foundation.dart';
import '../repositories/chat_repository.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatRepository _repo;

  ChatViewModel({ChatRepository? repository}) : _repo = repository ?? ChatRepository();

  bool _isLoading = false;
  List<dynamic> _threads = [];
  List<dynamic> _activeMessages = [];
  int? _activeThreadId;

  bool get isLoading => _isLoading;
  List<dynamic> get threads => _threads;
  List<dynamic> get activeMessages => _activeMessages;
  int? get activeThreadId => _activeThreadId;

  Future<void> loadMyThreads() async {
    _isLoading = true;
    notifyListeners();
    try {
      _threads = await _repo.fetchMyThreads();
    } catch (_) {
      _threads = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAdminThreads() async {
    _isLoading = true;
    notifyListeners();
    try {
      _threads = await _repo.fetchAdminThreads();
    } catch (_) {
      _threads = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> openThread(int threadId, {bool isAdmin = false}) async {
    _activeThreadId = threadId;
    _isLoading = true;
    notifyListeners();
    try {
      if (isAdmin) {
        _activeMessages = await _repo.fetchAdminMessages(threadId);
      } else {
        _activeMessages = await _repo.fetchMessages(threadId);
      }
    } catch (_) {
      _activeMessages = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendMessage(String text, {String? attachmentUrl}) async {
    if (_activeThreadId == null || text.trim().isEmpty) return false;
    try {
      final msg = await _repo.sendMessage(_activeThreadId!, text.trim(), attachmentUrl: attachmentUrl);
      _activeMessages.add(msg);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> adminReply(String text) async {
    if (_activeThreadId == null || text.trim().isEmpty) return false;
    try {
      final msg = await _repo.adminReply(_activeThreadId!, text.trim());
      _activeMessages.add(msg);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> updateThreadStatus(int threadId, String status) async {
    try {
      await _repo.updateThreadStatus(threadId, status);
      await loadAdminThreads();
    } catch (_) {}
  }
}
