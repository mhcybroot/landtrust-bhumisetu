class LocationHierarchyHelper {
  static List<String> getDistricts(List<dynamic> locations) {
    if (locations.isEmpty) return ['নোয়াখালী'];
    final set = <String>{};
    for (final loc in locations) {
      if (loc is Map && loc['districtNameBn'] != null) {
        set.add(loc['districtNameBn'].toString());
      }
    }
    return set.isNotEmpty ? set.toList() : ['নোয়াখালী'];
  }

  static List<Map<String, dynamic>> getPourashavas(List<dynamic> locations, {String district = 'নোয়াখালী'}) {
    return locations
        .whereType<Map<String, dynamic>>()
        .where((l) => l['districtNameBn'] == district && l['areaType'] == 'POURASHAVA')
        .toList();
  }

  static List<Map<String, dynamic>> getUpazilas(List<dynamic> locations, {String district = 'নোয়াখালী'}) {
    return locations
        .whereType<Map<String, dynamic>>()
        .where((l) => l['districtNameBn'] == district && (l['areaType'] == null || l['areaType'] == 'UPAZILA'))
        .toList();
  }

  static List<String> getAllAreaNames(List<dynamic> locations, {String district = 'নোয়াখালী'}) {
    final pourashavas = getPourashavas(locations, district: district).map((l) => l['upazilaNameBn'].toString()).toList();
    final upazilas = getUpazilas(locations, district: district).map((l) => l['upazilaNameBn'].toString()).toList();
    return [...pourashavas, ...upazilas];
  }

  static Map<String, dynamic>? findArea(List<dynamic> locations, String name) {
    for (final l in locations) {
      if (l is Map<String, dynamic> && l['upazilaNameBn'] == name) {
        return l;
      }
    }
    return null;
  }

  static List<String> getSubAreas(List<dynamic> locations, String areaName) {
    final area = findArea(locations, areaName);
    if (area == null) return [];
    final raw = area['subAreaNames']?.toString() ?? '';
    if (raw.trim().isEmpty) return [];
    return raw.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }

  static String getSubAreaLabel(List<dynamic> locations, String areaName) {
    final area = findArea(locations, areaName);
    final isWard = area?['subAreaType'] == 'WARD' || area?['areaType'] == 'POURASHAVA';
    return isWard ? 'পৌর ওয়ার্ড' : 'ইউনিয়ন';
  }

  static double calculateListingFee({
    required Map<String, dynamic>? settings,
    required String landType,
    required bool isFeatured,
  }) {
    if (settings == null) return 1000.0;
    double base = 1000.0;
    if (landType == 'কৃষি') {
      base = (settings['listingFeeAgri'] as num?)?.toDouble() ?? 500.0;
    } else if (landType == 'বাণিজ্যিক') {
      base = (settings['listingFeeCommercial'] as num?)?.toDouble() ?? 2000.0;
    } else if (landType == 'ফ্ল্যাট / অ্যাপার্টমেন্ট') {
      base = (settings['listingFeeFlat'] as num?)?.toDouble() ?? 1500.0;
    } else {
      base = (settings['listingFeeResidential'] as num?)?.toDouble() ?? 1000.0;
    }
    if (isFeatured) {
      final extra = (settings['listingFeeFeaturedExtra'] as num?)?.toDouble() ?? 1000.0;
      base += extra;
    }
    return base;
  }
}
