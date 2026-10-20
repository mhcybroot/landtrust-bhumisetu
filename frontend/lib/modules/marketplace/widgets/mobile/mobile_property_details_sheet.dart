import 'package:flutter/material.dart';
import '../../../../core/animations/bouncing_pressable.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/utils/whatsapp_helper.dart';
import '../../../../core/widgets/smart_image_viewer.dart';

class MobilePropertyDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> listing;
  final VoidCallback onInquiryClick;

  const MobilePropertyDetailsSheet({
    super.key,
    required this.listing,
    required this.onInquiryClick,
  });

  static void show(BuildContext context, {required Map<String, dynamic> listing, required VoidCallback onInquiryClick}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => MobilePropertyDetailsSheet(listing: listing, onInquiryClick: onInquiryClick),
    );
  }

  @override
  Widget build(BuildContext context) {
    final id = listing['id']?.toString() ?? '0';
    final title = listing['title']?.toString() ?? 'নামবিহীন জমি';
    final district = listing['district']?.toString() ?? 'নোয়াখালী';
    final upazila = listing['upazila']?.toString() ?? '';
    final area = listing['areaDecimals']?.toString() ?? '০';
    final price = listing['expectedPrice']?.toString() ?? '০';
    final landType = listing['landType']?.toString() ?? 'জমি';
    final photoUrl = listing['primaryPhotoUrl']?.toString();
    final description = listing['description']?.toString() ?? 'কোনো বিবরণ নেই';
    final dag = listing['dagNumber']?.toString();
    final khatian = listing['khatianNumber']?.toString();
    final mouza = listing['mouza']?.toString();

    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollController) {
        return Column(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 44,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: Hero(
                        tag: 'property_img_$id',
                        child: SmartImageViewer(url: photoUrl),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(8)),
                        child: Text(landType, style: const TextStyle(color: Color(0xFF0B4F32), fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      Text('৳$price', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0B4F32))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text('📍 $upazila, $district', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                  const SizedBox(height: 16),
                  const Divider(),
                  const Text('জমির বিবরণ ও তথ্যসূত্র:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 6),
                  Text(description, style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.black87)),
                  const SizedBox(height: 14),
                  _infoRow('জমির পরিমাণ', '$area শতক'),
                  if (mouza != null && mouza.isNotEmpty) _infoRow('মৌজা', mouza),
                  if (dag != null && dag.isNotEmpty) _infoRow('দাগ নম্বর', dag),
                  if (khatian != null && khatian.isNotEmpty) _infoRow('খতিয়ান নম্বর', khatian),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, -2))]),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: BouncingPressable(
                      onTap: () {
                        WhatsAppHelper.openPropertyInquiry(
                          rawPhone: listing['supportWhatsapp']?.toString() ?? listing['sellerPhone']?.toString(),
                          listing: listing,
                          isEnglish: context.isEnglish,
                        );
                      },
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(color: const Color(0xFF25D366), borderRadius: BorderRadius.circular(12)),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 18),
                            const SizedBox(width: 6),
                            Text(context.tr('whatsapp_chat'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 5,
                    child: BouncingPressable(
                      onTap: () {
                        Navigator.pop(context);
                        onInquiryClick();
                      },
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(color: const Color(0xFF0B4F32), borderRadius: BorderRadius.circular(12)),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.support_agent_rounded, color: Colors.white, size: 18),
                            const SizedBox(width: 6),
                            Text(context.tr('contact'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }


  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12.5)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
        ],
      ),
    );
  }
}
