import 'package:url_launcher/url_launcher.dart';
import 'whatsapp_helper.dart';

/// ব্যবহারকারী এবং অ্যাডমিনের মধ্যে দ্রুত যোগাযোগের ইউটিলিটি।
class CommunicationUtils {
  /// সরাসরি মোবাইল নম্বরে ডায়ালার ওপেন করে কল করার জন্য।
  static Future<bool> makePhoneCall(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleaned.isEmpty) return false;
    final uri = Uri(scheme: 'tel', path: cleaned);
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      }
    } catch (_) {}
    return false;
  }

  /// কাস্টম মেসেজ সহ হোয়াটসঅ্যাপে চ্যাট শুরু করার মেথড।
  static Future<bool> launchWhatsApp({
    required String phone,
    required String message,
  }) async {
    return WhatsAppHelper.openChat(phone: phone, message: message);
  }

  /// পেন্ডিং পেমেন্ট যাচাই সংক্রান্ত মেসেজ তৈরি করে হোয়াটসঅ্যাপ খোলা।
  static Future<bool> openPaymentVerificationChat({
    required String phone,
    required String userName,
    required String trxId,
    String? method,
  }) async {
    final text = 'আসসালামু আলাইকুম $userName,\n'
        'LandApp থেকে যোগাযোগ করা হচ্ছে। আপনার মেম্বারশিপ ফি যাচাইয়ের জন্য:\n'
        '• মাধ্যম: ${method ?? 'মোবাইল ব্যাংকিং'}\n'
        '• TrxID: $trxId\n'
        'অনুগ্রহ করে পেমেন্টের সঠিক প্রমাণ বা স্ক্রিনশট শেয়ার করুন। ধন্যবাদ!';
    return launchWhatsApp(phone: phone, message: text);
  }

  /// লিস্টিং যাচাই বা আপডেট সংক্রান্ত মেসেজ।
  static Future<bool> openListingReviewChat({
    required String phone,
    required String userName,
    required String listingTitle,
    required String listingId,
  }) async {
    final text = 'আসসালামু আলাইকুম $userName,\n'
        'LandApp থেকে আপনার পোস্টকৃত জমিটির বিষয়ে যোগাযোগ করছি:\n'
        '• শিরোনাম: $listingTitle\n'
        '• আইডি: #$listingId\n'
        'জমির কাগজপত্র যাচাই সংক্রান্ত বিষয়ে কিছু তথ্য প্রয়োজন।';
    return launchWhatsApp(phone: phone, message: text);
  }

  /// ক্রেতার ডিমান্ড বা ইনকোয়ারি সংক্রান্ত মেসেজ।
  static Future<bool> openDemandInquiryChat({
    required String phone,
    required String userName,
    required String demandTitle,
  }) async {
    final text = 'আসসালামু আলাইকুম $userName,\n'
        'LandApp-এ আপনার চাহিদাকৃত জমি ($demandTitle) এর বিষয়ে কিছু উপযুক্ত প্রস্তাবনা রয়েছে। বিস্তারিত আলোচনার জন্য যোগাযোগ করছি।';
    return launchWhatsApp(phone: phone, message: text);
  }
}
