import 'package:url_launcher/url_launcher.dart';

/// হোয়াটসঅ্যাপে সরাসরি চ্যাট ওপেন করার হেল্পার ইউটিলিটি।
class WhatsAppHelper {
  static String formatPhoneNumber(String phone) {
    var cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.startsWith('01') && cleaned.length == 11) {
      cleaned = '88$cleaned';
    }
    return cleaned.isEmpty ? '8801700000000' : cleaned;
  }

  /// নির্দিষ্ট জমির বিস্তারিত তথ্যসহ হোয়াটসঅ্যাপ চ্যাট ওপেন করে।
  static Future<bool> openPropertyInquiry({
    required String? rawPhone,
    required Map<String, dynamic> listing,
    bool isEnglish = false,
  }) async {
    final phone = formatPhoneNumber(rawPhone ?? '');
    final title = listing['title']?.toString() ?? 'নামবিহীন জমি';
    final district = listing['district']?.toString() ?? 'নোয়াখালী';
    final upazila = listing['upazila']?.toString() ?? '';
    final price = listing['expectedPrice']?.toString() ?? '০';
    final id = listing['id']?.toString() ?? '';

    final String message;
    if (isEnglish) {
      message = 'Hello! I am interested in this land listed on Bhumi Setu:\n'
          '📌 Title: $title\n'
          '📍 Location: $upazila, $district\n'
          '💰 Price: ৳$price\n'
          '🔗 Listing ID: #$id\n'
          'Please provide more details.';
    } else {
      message = 'আসসালামু আলাইকুম। আমি ভূমি সেতু অ্যাপে এই জমিটি সম্পর্কে জানতে আগ্রহী:\n'
          '📌 শিরোনাম: $title\n'
          '📍 এলাকা: $upazila, $district\n'
          '💰 মূল্য: ৳$price\n'
          '🔗 লিস্টিং আইডি: #$id\n'
          'অনুগ্রহ করে বিস্তারিত জানান।';
    }

    return openChat(phone: phone, message: message);
  }

  /// সরাসরি কাস্টম মেসেজসহ চ্যাট ওপেন করার মেথড।
  static Future<bool> openChat({required String phone, required String message}) async {
    final cleanedPhone = formatPhoneNumber(phone);
    final encoded = Uri.encodeComponent(message);
    final urlString = 'https://wa.me/$cleanedPhone?text=$encoded';
    final uri = Uri.parse(urlString);

    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        return await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      return false;
    }
  }
}
