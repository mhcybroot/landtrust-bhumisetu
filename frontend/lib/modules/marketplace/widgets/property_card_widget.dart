import 'package:flutter/material.dart';
import '../../../../core/animations/hover_lift_card.dart';
import '../../../../core/animations/pulse_beacon_indicator.dart';
import '../../../../core/animations/transitions/finance_payment_transitions.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/utils/whatsapp_helper.dart';
import '../../../../core/widgets/smart_image_viewer.dart';
import '../../../../core/widgets/status_badge.dart';

class PropertyCardWidget extends StatelessWidget {
  final Map<String, dynamic> listing;
  final bool isMobile;
  final VoidCallback onDetailsClick;
  final VoidCallback onInquiryClick;

  const PropertyCardWidget({
    super.key,
    required this.listing,
    required this.isMobile,
    required this.onDetailsClick,
    required this.onInquiryClick,
  });

  @override
  Widget build(BuildContext context) {
    final vStatus = listing['verificationStatus'] as String? ?? 'SUBMITTED';
    final hasVideo = (listing['videoUrl'] ?? '').toString().trim().isNotEmpty;
    final hasMap = (listing['mapLink'] ?? '').toString().trim().isNotEmpty;

    return HoverLiftCard(
      onTap: onDetailsClick,
      borderRadius: BorderRadius.circular(14),
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: onDetailsClick,
              child: Stack(
                children: [
                  Hero(
                    tag: 'property_img_${listing['id'] ?? 'unknown'}',
                    child: SmartImageViewer(
                      url: listing['imageUrl'] as String?,
                      height: isMobile ? 180 : 200,
                      width: double.infinity,
                      enableZoom: false,
                    ),
                  ),
                  Positioned(top: 10, left: 10, child: VerificationBadge(status: vStatus)),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFF0B4F32), borderRadius: BorderRadius.circular(20)),
                      child: Text(listing['landType'] ?? 'আবাসিক', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  if (hasVideo || hasMap)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Wrap(
                        spacing: 4,
                        children: [
                          if (hasVideo) _mediaIndicator(Icons.play_circle_fill, 'ভিডিও', Colors.red.shade700, showPulse: true),
                          if (hasMap) _mediaIndicator(Icons.map, 'ম্যাপ', Colors.blue.shade800),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing['title'] ?? '',
                    style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 15, color: Color(0xFF0B4F32)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${listing['areaName']}, ${listing['upazila']}, ${listing['district']}',
                          style: const TextStyle(fontSize: 12.5, color: Colors.black87),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFFF3F8F5), borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('পরিমাণ', style: TextStyle(fontSize: 10.5, color: Colors.black54)),
                              Text('${listing['areaDecimal']} শতাংশ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                            ],
                          ),
                        ),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('মূল্য', style: TextStyle(fontSize: 10.5, color: Colors.black54)),
                              TkCurrencyRollingOdometerTransition(amount: int.tryParse(listing['expectedPriceBdt']?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? '') ?? 0),
                              if (listing['pricePerDecimalBdt'] != null)
                                Text('(৳${listing['pricePerDecimalBdt']}/শতাংশ)', style: const TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF25D366), size: 20),
                        tooltip: context.tr('whatsapp_chat'),
                        onPressed: () => WhatsAppHelper.openPropertyInquiry(
                          rawPhone: listing['supportWhatsapp']?.toString() ?? listing['sellerPhone']?.toString(),
                          listing: listing,
                          isEnglish: context.isEnglish,
                        ),
                      ),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          onPressed: onDetailsClick,
                          child: Text(context.tr('details'), style: const TextStyle(fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          onPressed: onInquiryClick,
                          child: Text(context.tr('contact'), style: const TextStyle(fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mediaIndicator(IconData icon, String label, Color color, {bool showPulse = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showPulse) ...[
            const PulseBeaconIndicator(color: Colors.white, size: 5),
            const SizedBox(width: 4),
          ],
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 3),
          Text(label, style: const TextStyle(fontSize: 9.5, color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
