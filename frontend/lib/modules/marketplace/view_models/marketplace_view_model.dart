import 'package:flutter/foundation.dart';
import '../repositories/marketplace_repository.dart';

class MarketplaceViewModel extends ChangeNotifier {
  final MarketplaceRepository _repo;

  Map<String, dynamic> _config = {};
  List<dynamic> _listings = [];
  List<dynamic> _requirements = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Filter States
  String _filterDistrict = '';
  String _filterUpazila = '';
  String _filterLandType = '';
  String _filterVerification = '';
  String _keyword = '';
  String? _maxBudget;
  String? _minArea;
  String? _maxArea;
  bool _filtersExpanded = false;

  MarketplaceViewModel({MarketplaceRepository? repository})
      : _repo = repository ?? MarketplaceRepository();

  Map<String, dynamic> get config => _config;
  List<dynamic> get listings => _listings;
  List<dynamic> get requirements => _requirements;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get filterDistrict => _filterDistrict;
  String get filterUpazila => _filterUpazila;
  String get filterLandType => _filterLandType;
  String get filterVerification => _filterVerification;
  String get keyword => _keyword;
  String? get maxBudget => _maxBudget;
  String? get minArea => _minArea;
  String? get maxArea => _maxArea;
  bool get filtersExpanded => _filtersExpanded;

  Map<String, dynamic> get stats => {
        'publishedListings': _listings.length,
        'activeBuyerRequirements': _requirements.length,
        'marketingOfficers': (_config['stats']?['marketingOfficers'] ?? 14),
        'coveredUpazilas': (_config['locations'] as List?)?.length ?? 9,
      };

  void setFilterDistrict(String val) {
    _filterDistrict = val;
    _filterUpazila = '';
    notifyListeners();
  }

  void setFilterUpazila(String val) {
    _filterUpazila = val;
    notifyListeners();
  }

  void setFilterLandType(String val) {
    _filterLandType = _filterLandType == val ? '' : val;
    notifyListeners();
    loadListings();
  }

  void setFilterVerification(String val) {
    _filterVerification = _filterVerification == val ? '' : val;
    notifyListeners();
    loadListings();
  }

  void setKeyword(String val) {
    _keyword = val;
  }

  void toggleFiltersExpanded() {
    _filtersExpanded = !_filtersExpanded;
    notifyListeners();
  }

  void resetFilters() {
    _filterDistrict = '';
    _filterUpazila = '';
    _filterLandType = '';
    _filterVerification = '';
    _keyword = '';
    _maxBudget = null;
    _minArea = null;
    _maxArea = null;
    notifyListeners();
    loadListings();
  }

  Future<void> loadInitialData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final configRes = await _repo.fetchPublicConfig();
      _config = configRes;
      final results = await Future.wait([
        _repo.fetchListings(),
        _repo.fetchBuyerDemands(),
      ]);
      _listings = results[0];
      _requirements = results[1];
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadListings({
    String? customBudget,
    String? customMinArea,
    String? customMaxArea,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _listings = await _repo.fetchListings(
        district: _filterDistrict,
        upazila: _filterUpazila,
        landType: _filterLandType,
        verification: _filterVerification,
        keyword: _keyword,
        maxBudget: customBudget ?? _maxBudget,
        minArea: customMinArea ?? _minArea,
        maxArea: customMaxArea ?? _maxArea,
      );
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendInquiry(int listingId, double budget, String msg) async {
    await _repo.sendInquiry(
      listingId: listingId,
      proposedBudget: budget,
      message: msg,
    );
  }

  Future<void> sendSellerOffer(int reqId, String notes, double price, double fee) async {
    await _repo.sendSellerOffer(
      requirementId: reqId,
      description: notes,
      expectedPrice: price,
      commissionFee: fee,
    );
  }
}
