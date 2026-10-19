import 'package:landtrust_app/core/network/api_client.dart';

class MarketplaceRepository {
  Future<Map<String, dynamic>> fetchPublicConfig() async {
    final res = await ApiClient.get('/public/config');
    final data = ApiClient.parseResponse(res);
    return data is Map<String, dynamic> ? data : {};
  }

  Future<List<dynamic>> fetchListings({
    String district = '',
    String upazila = '',
    String landType = '',
    String verification = '',
    String keyword = '',
    String? maxBudget,
    String? minArea,
    String? maxArea,
  }) async {
    final queryParams = <String, String>{};
    if (district.isNotEmpty) queryParams['district'] = district;
    if (upazila.isNotEmpty) queryParams['upazila'] = upazila;
    if (landType.isNotEmpty) queryParams['landType'] = landType;
    if (verification.isNotEmpty) queryParams['verification'] = verification;
    if (keyword.isNotEmpty) queryParams['keyword'] = keyword;
    if (maxBudget != null && maxBudget.isNotEmpty) queryParams['maxBudget'] = maxBudget;
    if (minArea != null && minArea.isNotEmpty) queryParams['minArea'] = minArea;
    if (maxArea != null && maxArea.isNotEmpty) queryParams['maxArea'] = maxArea;

    final query = queryParams.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
    final path = query.isEmpty ? '/public/listings' : '/public/listings?$query';
    final res = await ApiClient.get(path);
    final data = ApiClient.parseResponse(res);
    return data is List ? data : [];
  }

  Future<List<dynamic>> fetchBuyerDemands() async {
    final res = await ApiClient.get('/public/requirements');
    final data = ApiClient.parseResponse(res);
    return data is List ? data : [];
  }

  Future<Map<String, dynamic>> sendInquiry({
    required int listingId,
    required double proposedBudget,
    required String message,
  }) async {
    final res = await ApiClient.post('/member/buyer/inquiries', body: {
      'listingId': listingId,
      'proposedBudgetBdt': proposedBudget,
      'buyerNotes': message,
    });
    return ApiClient.parseResponse(res) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> sendSellerOffer({
    required int requirementId,
    required String description,
    required double expectedPrice,
    required double commissionFee,
  }) async {
    final res = await ApiClient.post('/member/seller/proposals', body: {
      'buyerRequirementId': requirementId,
      'sellerNotes': description,
      'proposedTotalBdt': expectedPrice,
      'customerProposedFeeBdt': commissionFee,
    });
    return ApiClient.parseResponse(res) as Map<String, dynamic>;
  }

  Future<void> recordShare(int listingId, String channel) async {
    try {
      await ApiClient.post('/public/listings/$listingId/share?channel=$channel');
    } catch (_) {}
  }
}
