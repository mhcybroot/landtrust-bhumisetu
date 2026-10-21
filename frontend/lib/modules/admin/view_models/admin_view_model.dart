import 'package:flutter/foundation.dart';
import '../repositories/admin_repository.dart';

class AdminViewModel extends ChangeNotifier {
  final AdminRepository _repo;

  int _selectedTab = 0;
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic> _dashboard = {};
  List<dynamic> _users = [];
  List<dynamic> _listings = [];
  List<dynamic> _requirements = [];
  List<dynamic> _inquiries = [];
  List<dynamic> _commissions = [];
  List<dynamic> _proposals = [];
  List<dynamic> _transactions = [];
  List<dynamic> _paymentMethods = [];
  List<dynamic> _locations = [];

  AdminViewModel({AdminRepository? repository})
      : _repo = repository ?? AdminRepository();

  int get selectedTab => _selectedTab;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Map<String, dynamic> get dashboard => _dashboard;
  List<dynamic> get users => _users;
  List<dynamic> get listings => _listings;
  List<dynamic> get requirements => _requirements;
  List<dynamic> get inquiries => _inquiries;
  List<dynamic> get commissions => _commissions;
  List<dynamic> get proposals => _proposals;
  List<dynamic> get transactions => _transactions;
  List<dynamic> get paymentMethods => _paymentMethods;
  List<dynamic> get locations => _locations;

  void selectTab(int index) {
    _selectedTab = index;
    notifyListeners();
  }

  Future<void> loadAllData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _repo.fetchDashboard(),
        _repo.fetchUsers(),
        _repo.fetchListings(),
        _repo.fetchRequirements(),
        _repo.fetchInquiries(),
        _repo.fetchCommissions(),
        _repo.fetchProposals(),
        _repo.fetchTransactions(),
        _repo.fetchPaymentMethods(),
        _repo.fetchLocations(),
      ]);
      _dashboard = results[0] as Map<String, dynamic>;
      _users = results[1] as List<dynamic>;
      _listings = results[2] as List<dynamic>;
      _requirements = results[3] as List<dynamic>;
      _inquiries = results[4] as List<dynamic>;
      _commissions = results[5] as List<dynamic>;
      _proposals = results[6] as List<dynamic>;
      _transactions = results[7] as List<dynamic>;
      _paymentMethods = results[8] as List<dynamic>;
      _locations = results[9] as List<dynamic>;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyUserPayment(int userId, bool isApproved, String? note) async {
    await _repo.verifyUserPayment(userId, isApproved, note);
    _users = await _repo.fetchUsers();
    notifyListeners();
  }

  Future<void> resetUserPassword(int userId, String pass) async {
    await _repo.resetUserPassword(userId, pass);
  }

  Future<void> refundUserFee(int userId, String reason, String trxId) async {
    await _repo.refundUserFee(userId, reason, trxId);
    _users = await _repo.fetchUsers();
    notifyListeners();
  }

  Future<void> verifyListing(int listingId, String status, String? notes) async {
    await _repo.verifyListing(listingId, status, notes);
    _listings = await _repo.fetchListings();
    notifyListeners();
  }

  Future<void> verifyRequirement(int reqId, bool isApproved) async {
    await _repo.verifyRequirement(reqId, isApproved);
    _requirements = await _repo.fetchRequirements();
    notifyListeners();
  }

  Future<void> awardCommission(Map<String, dynamic> payload) async {
    await _repo.awardCommission(payload);
    _commissions = await _repo.fetchCommissions();
    notifyListeners();
  }

  Future<void> markCommissionPaid(int id, String paymentRef) async {
    await _repo.markCommissionPaid(id, paymentRef);
    _commissions = await _repo.fetchCommissions();
    notifyListeners();
  }

  Future<void> respondProposal(int id, String action, {String? notes, double? agreedFee}) async {
    await _repo.respondProposal(id, action, notes: notes, agreedFee: agreedFee);
    _proposals = await _repo.fetchProposals();
    notifyListeners();
  }

  Future<void> addExpense(Map<String, dynamic> payload) async {
    await _repo.addExpense(payload);
    _transactions = await _repo.fetchTransactions();
    _dashboard = await _repo.fetchDashboard();
    notifyListeners();
  }

  Future<void> createPaymentMethod(Map<String, dynamic> payload) async {
    await _repo.createPaymentMethod(payload);
    _paymentMethods = await _repo.fetchPaymentMethods();
    notifyListeners();
  }

  Future<void> deletePaymentMethod(int id) async {
    await _repo.deletePaymentMethod(id);
    _paymentMethods = await _repo.fetchPaymentMethods();
    notifyListeners();
  }

  Future<void> createLocation(Map<String, dynamic> payload) async {
    await _repo.createLocation(payload);
    _locations = await _repo.fetchLocations();
    notifyListeners();
  }

  Future<void> deleteLocation(int id) async {
    await _repo.deleteLocation(id);
    _locations = await _repo.fetchLocations();
    notifyListeners();
  }

  Future<void> updateSettings(Map<String, dynamic> payload) async {
    await _repo.updateSettings(payload);
    _dashboard = await _repo.fetchDashboard();
    notifyListeners();
  }

  Future<void> sendNotificationToUser(int userId, String title, String message) async {
    await _repo.sendNotificationToUser(userId, title, message);
  }

  Future<void> broadcastNotification(String title, String message, {String? role}) async {
    await _repo.broadcastNotification(title, message, role: role);
  }
}
