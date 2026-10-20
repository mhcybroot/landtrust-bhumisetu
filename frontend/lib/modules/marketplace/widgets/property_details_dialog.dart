import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/utils/whatsapp_helper.dart';
import '../../../../core/widgets/smart_image_viewer.dart';

class PropertyDetailsDialog {
  static void show(
    BuildContext context, {
    required Map<String, dynamic> listing,
    required bool isMobile,
    required VoidCallback onInquiryClick,
  }) {
    final mainImg = (listing['imageUrl'] ?? '').toString().trim();
    final extraRaw = (listing['additionalImageUrls'] ?? '').toString().trim();
    final extraImages = extraRaw.isEmpty
        ? <String>[]
        : extraRaw.split('|||').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    final allImages = <String>[if (mainImg.isNotEmpty) mainImg, ...extraImages];
    int activeImgIndex = 0;
    final videoUrl = (listing['videoUrl'] ?? '').toString().trim();
    final mapLink = (listing['mapLink'] ?? '').toString().trim();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: isMobile ? 16 : 24),
          titlePadding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          actionsPadding: const EdgeInsets.all(12),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  listing['title'] ?? 'জমির বিস্তারিত তথ্য',
                  style: TextStyle(fontSize: isMobile ? 16 : 18, fontWeight: FontWeight.bold, color: const Color(0xFF0B4F32)),
                ),
              ),
              IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
            ],
          ),
          content: SizedBox(
            width: isMobile ? double.infinity : 680,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (allImages.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SmartImageViewer(
                        url: allImages[activeImgIndex],
                        height: isMobile ? 210 : 280,
                        width: double.infinity,
                        enableZoom: true,
                      ),
                    ),
                    if (allImages.length > 1) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 58,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: allImages.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 6),
                          itemBuilder: (_, idx) => InkWell(
                            onTap: () => setDialogState(() => activeImgIndex = idx),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: idx == activeImgIndex ? const Color(0xFF0B4F32) : Colors.grey.shade300,
                                  width: idx == activeImgIndex ? 2.5 : 1,
                                ),
                              ),
                              child: SmartImageViewer(url: allImages[idx], width: 72, height: 54, borderRadius: BorderRadius.circular(4), enableZoom: false),
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                  ],
                  _buildDetailsBox(listing),
                  const SizedBox(height: 12),
                  const Text('বিস্তারিত বিবরণ:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(listing['description'] ?? 'কোনো অতিরিক্ত বিবরণ দেওয়া হয়নি।', style: const TextStyle(fontSize: 13, height: 1.4)),
                  if (videoUrl.isNotEmpty || mapLink.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      if (videoUrl.isNotEmpty) _copyBtn(context, 'ভিডিও লিংক কপি', videoUrl, Icons.play_circle_outline, Colors.red),
                      if (mapLink.isNotEmpty) _copyBtn(context, 'Google Maps লিংক কপি', mapLink, Icons.pin_drop_outlined, Colors.blue),
                    ]),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(ctx.tr('close'))),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), foregroundColor: Colors.white),
              onPressed: () {
                WhatsAppHelper.openPropertyInquiry(
                  rawPhone: listing['supportWhatsapp']?.toString() ?? listing['sellerPhone']?.toString(),
                  listing: listing,
                  isEnglish: ctx.isEnglish,
                );
              },
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 17),
              label: Text(ctx.tr('whatsapp_chat')),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(ctx);
                onInquiryClick();
              },
              icon: const Icon(Icons.support_agent, size: 17),
              label: Text(ctx.tr('contact')),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildDetailsBox(Map<String, dynamic> l) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF3F8F5), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF0B4F32).withValues(alpha: 0.2))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 12, runSpacing: 4, alignment: WrapAlignment.spaceBetween, children: [
          Text('মোট মূল্য: ৳${l['expectedPriceBdt']}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0B4F32))),
          Text('প্রতি শতাংশ: ৳${l['pricePerDecimalBdt'] ?? '-'} (${l['areaDecimal']} শতাংশ)', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ]),
        const Divider(height: 16),
        Text('📍 অবস্থান: ${l['areaName']}, ${l['upazila']}, ${l['district']}'),
        const SizedBox(height: 3),
        Text('🗺️ মৌজা: ${l['mouzaName'] ?? 'উল্লেখ নেই'}  •  ধরন: ${l['landType']}'),
        const SizedBox(height: 3),
        Text('🛣️ রাস্তার তথ্য: ${l['roadAccessInfo'] ?? 'পাকা রাস্তা সংলগ্ন'}'),
        const SizedBox(height: 3),
        const Text('🔒 গোপনীয়তা: খতিয়ান/দাগ ও মালিকের নম্বর প্ল্যাটফর্ম মধ্যস্থতায় সংরক্ষিত।', style: TextStyle(fontSize: 11, color: Colors.black54)),
      ]),
    );
  }

  static Widget _copyBtn(BuildContext ctx, String label, String text, IconData icon, Color color) {
    return OutlinedButton.icon(
      icon: Icon(icon, color: color, size: 16),
      label: Text(label),
      onPressed: () {
        Clipboard.setData(ClipboardData(text: text));
        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('$label: $text')));
      },
    );
  }
}
