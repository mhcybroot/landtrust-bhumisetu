import 'package:flutter/foundation.dart';
import 'package:landtrust_app/core/session/session_manager.dart';

class ShellViewModel extends ChangeNotifier {
  int _selectedTabIndex = 0;

  ShellViewModel() {
    SessionManager.instance.addListener(_onSessionChanged);
  }

  @override
  void dispose() {
    SessionManager.instance.removeListener(_onSessionChanged);
    super.dispose();
  }

  void _onSessionChanged() {
    notifyListeners();
  }

  int get selectedTabIndex => _selectedTabIndex;
  Map<String, dynamic>? get currentUser => SessionManager.instance.currentUser;
  bool get isLoggedIn => SessionManager.instance.isLoggedIn;
  bool get isAdmin => currentUser?['role'] == 'ADMIN';

  void setTabIndex(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  Future<void> logout() async {
    await SessionManager.instance.clearSession();
    _selectedTabIndex = 0;
    notifyListeners();
  }
}
