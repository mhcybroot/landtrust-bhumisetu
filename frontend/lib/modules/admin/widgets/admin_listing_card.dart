import 'package:flutter/material.dart';
import 'package:landtrust_app/core/utils/whatsapp_helper.dart';
import 'package:landtrust_app/core/widgets/smart_image_viewer.dart';
import 'package:landtrust_app/core/widgets/status_badge.dart';
import 'package:landtrust_app/modules/member_portal/widgets/private_document_preview_dialog.dart';

class AdminListingCard extends StatelessWidget {
  final Map<String, dynamic> listing;
  final bool isMobile;
  final VoidCallback onVerifyTap;
  final Future<void> Function() onApproveTap;

  const AdminListingCard({
    super.key,
    required this.listing,
    required this.isMobile,
    required this.onVerifyTap,
    required this.onApproveTap,
  });

  @override
  Widget build(BuildContext context) {
    final l = listing;
    final hasDoc = l['privateDocumentUrl'] != null && l['privateDocumentUrl'].toString().isNotEmpty;
    final isPendingPayment = (l['paymentStatus'] ?? 'PENDING') == 'PENDING';
    final isApproved = l['listingStatus'] == 'APPROVED_PUBLISHED';
    final fee = (l['listingFeeChargedBdt'] as num?)?.toDouble() ?? 0;
    final isFeatured = l['isFeatured'] == true || l['featured'] == true;
    final subArea = l['subArea']?.toString();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SmartImageViewer(url: l['imageUrl'] as String?, height: isMobile ? 65 : 75, width: isMobile ? 85 : 100),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(l['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                          if (isFeatured)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(4)),
                              child: const Text('⭐ ফিচার্ড', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.brown)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Wrap(spacing: 6, runSpacing: 4, children: [
                        VerificationBadge(status: l['verificationStatus']),
                        StatusBadge(status: l['listingStatus']),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isPendingPayment ? Colors.orange.shade50 : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: isPendingPayment ? Colors.orange.shade300 : Colors.green.shade300),
                          ),
                          child: Text(
                            isPendingPayment ? 'পেমেন্ট: অপেক্ষমান' : 'পেমেন্ট: অনুমোদিত',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isPendingPayment ? Colors.orange.shade800 : Colors.green.shade800),
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'অবস্থান: ${l['areaName'] ?? ''}${subArea != null && subArea.isNotEmpty ? ', $subArea' : ''}, ${l['upazila']}, ${l['district']} • মৌজা: ${l['mouzaName'] ?? '-'}',
              style: const TextStyle(fontSize: 12.5),
            ),
            const SizedBox(height: 2),
            Text(
              'পরিমাণ: ${l['areaDecimal']} শতাংশ • মূল্য: ৳${l['expectedPriceBdt']}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B4F32)),
            ),
            if (fee > 0 || l['transactionId'] != null) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                child: Text(
                  '💳 ফি: ৳$fee | মাধ্যম: ${l['paymentMethod'] ?? '-'} | প্রেরক: ${l['senderPhone'] ?? '-'} | TrxID: ${l['transactionId'] ?? '-'}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (!isApproved)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
                    onPressed: onApproveTap,
                    icon: const Icon(Icons.check_circle, size: 15),
                    label: const Text('পেমেন্ট ও বিজ্ঞাপন অনুমোদন', style: TextStyle(fontSize: 11)),
                  ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey, foregroundColor: Colors.white),
                  onPressed: onVerifyTap,
                  icon: const Icon(Icons.verified, size: 15),
                  label: const Text('যাচাইকরণ স্ট্যাটাস', style: TextStyle(fontSize: 11)),
                ),
                if (hasDoc)
                  OutlinedButton.icon(
                    onPressed: () => PrivateDocumentPreviewDialog.show(context, listing: l, isMobile: isMobile),
                    icon: const Icon(Icons.description, size: 15),
                    label: const Text('দলিল', style: TextStyle(fontSize: 11)),
                  ),
                if (l['sellerPhone'] != null)
                  OutlinedButton.icon(
                    onPressed: () => WhatsAppHelper.openChat(
                      phone: l['sellerPhone'].toString(),
                      message: 'আসসালামু আলাইকুম, ভূমি সেতু থেকে আপনার লিস্টিং "${l['title']}" এর TrxID ও তথ্য যাচাই সংক্রান্ত যোগাযোগ করছি।',
                    ),
                    icon: const Icon(Icons.chat, size: 14, color: Colors.green),
                    label: const Text('WhatsApp', style: TextStyle(fontSize: 11, color: Colors.green)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
