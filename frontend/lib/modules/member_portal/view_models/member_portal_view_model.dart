import 'package:flutter/foundation.dart';
import 'package:landtrust_app/core/network/api_client.dart';
import 'package:landtrust_app/core/session/session_manager.dart';
import '../repositories/member_repository.dart';

class MemberPortalViewModel extends ChangeNotifier {
  final MemberRepository _repo;

  Map<String, dynamic> _publicConfig = {};
  Map<String, dynamic> _notificationsData = {'notifications': [], 'unreadCount': 0};
  Map<String, dynamic> _officerDashboard = {};
  List<dynamic> _myListings = [];
  List<dynamic> _myRequirements = [];
  List<dynamic> _myInquiries = [];
  List<dynamic> _myProposals = [];
  String _activePortalMode = '';
  bool _isLoading = false;
  String? _errorMessage;

  MemberPortalViewModel({MemberRepository? repository})
      : _repo = repository ?? MemberRepository();

  Map<String, dynamic>? get currentUser => SessionManager.instance.currentUser;
  Map<String, dynamic> get publicConfig => _publicConfig;
  Map<String, dynamic> get notificationsData => _notificationsData;
  Map<String, dynamic> get officerDashboard => _officerDashboard;
  List<dynamic> get myListings => _myListings;
  List<dynamic> get myRequirements => _myRequirements;
  List<dynamic> get myInquiries => _myInquiries;
  List<dynamic> get myProposals => _myProposals;
  String get activePortalMode => _activePortalMode;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void switchMode(String mode) {
    _activePortalMode = mode;
    notifyListeners();
  }

  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repo.refreshProfile();
      final configRes = await ApiClient.get('/public/config');
      _publicConfig = ApiClient.parseResponse(configRes) as Map<String, dynamic>;
      _notificationsData = await _repo.fetchNotifications();

      final role = currentUser?['role']?.toString() ?? 'BUYER';
      if (_activePortalMode.isEmpty) {
        _activePortalMode = (role == 'UPAZILA_AGENT' || role == 'DISTRICT_AGENT') ? 'MARKETING_OFFICER' : (role == 'ADMIN' ? 'SELLER' : role);
      }
      if (role == 'MARKETING_OFFICER' || role == 'UPAZILA_AGENT' || role == 'DISTRICT_AGENT') {
        _officerDashboard = await _repo.fetchOfficerDashboard();
      }

      final results = await Future.wait([
        _repo.fetchSellerListings(),
        _repo.fetchBuyerRequirements(),
        _repo.fetchBuyerInquiries(),
        _repo.fetchProposals(),
      ]);
      _myListings = results[0];
      _myRequirements = results[1];
      _myInquiries = results[2];
      _myProposals = results[3];
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markNotificationRead(int id) async {
    try {
      await _repo.markNotificationRead(id);
      _notificationsData = await _repo.fetchNotifications();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> markAllNotificationsRead() async {
    try {
      await _repo.markAllNotificationsRead();
      _notificationsData = await _repo.fetchNotifications();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> createListing(Map<String, dynamic> payload) async {
    await _repo.createListing(payload);
    _myListings = await _repo.fetchSellerListings();
    notifyListeners();
  }

  Future<void> updateListing(int id, Map<String, dynamic> payload) async {
    await _repo.updateListing(id, payload);
    _myListings = await _repo.fetchSellerListings();
    notifyListeners();
  }

  Future<void> createRequirement(Map<String, dynamic> payload) async {
    await _repo.createRequirement(payload);
    _myRequirements = await _repo.fetchBuyerRequirements();
    notifyListeners();
  }

  Future<void> updateRequirement(int id, Map<String, dynamic> payload) async {
    await _repo.updateRequirement(id, payload);
    _myRequirements = await _repo.fetchBuyerRequirements();
    notifyListeners();
  }

  Future<void> respondProposal(int id, String action, {String? notes}) async {
    await _repo.respondProposal(id, action, notes: notes);
    _myProposals = await _repo.fetchProposals();
    notifyListeners();
  }

  Future<void> requestOfficerPayout(double amount, String method, String account) async {
    await _repo.requestOfficerPayout(amount, method, account);
    _officerDashboard = await _repo.fetchOfficerDashboard();
    notifyListeners();
  }

  Future<void> resubmitPayment(String method, String phone, String trxId) async {
    await _repo.resubmitPayment(method, phone, trxId);
    await _repo.refreshProfile();
    notifyListeners();
  }

  Future<void> updateProfile(String name, String district, String upazila, String address) async {
    await _repo.updateProfile(name, district, upazila, address);
    await _repo.refreshProfile();
    notifyListeners();
  }

  Future<void> changePassword(String oldPass, String newPass) async {
    await _repo.changePassword(oldPass, newPass);
  }
}
