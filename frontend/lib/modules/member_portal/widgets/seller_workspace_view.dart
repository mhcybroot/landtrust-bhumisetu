import 'package:flutter/material.dart';
import 'package:landtrust_app/core/widgets/smart_image_viewer.dart';
import 'package:landtrust_app/core/widgets/status_badge.dart';

class SellerWorkspaceView extends StatelessWidget {
  final List<dynamic> myListings;
  final bool isMobile;
  final VoidCallback onAddListing;
  final VoidCallback onAddProposal;
  final Function(Map<String, dynamic>) onEditListing;
  final Function(Map<String, dynamic>) onPreviewDoc;
  final Future<void> Function(int) onMarkSold;

  const SellerWorkspaceView({
    super.key,
    required this.myListings,
    required this.isMobile,
    required this.onAddListing,
    required this.onAddProposal,
    required this.onEditListing,
    required this.onPreviewDoc,
    required this.onMarkSold,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 8,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'আমার জমির বিজ্ঞাপন (${myListings.length})',
              style: TextStyle(fontSize: isMobile ? 17 : 19, fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B4F32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  onPressed: onAddListing,
                  icon: const Icon(Icons.add_home_work, size: 16),
                  label: const Text('নতুন বিজ্ঞাপন জমা দিন', style: TextStyle(fontSize: 12)),
                ),
                OutlinedButton.icon(
                  onPressed: onAddProposal,
                  icon: const Icon(Icons.handshake, size: 16),
                  label: const Text('বিশেষ সেবা প্রস্তাব', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (myListings.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('আপনি এখনো কোনো জমির বিজ্ঞাপন জমা দেননি। উপরের বাটনে ক্লিক করে তথ্য জমা দিন।'),
            ),
          )
        else
          ...myListings.map((l) {
            final item = l as Map<String, dynamic>;
            final hasDoc = item['privateDocumentUrl'] != null && item['privateDocumentUrl'].toString().isNotEmpty;
            final isSold = item['listingStatus'] == 'SOLD';

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
                          child: SmartImageViewer(
                            url: item['imageUrl'] as String?,
                            height: isMobile ? 60 : 70,
                            width: isMobile ? 80 : 95,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'] ?? '',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  VerificationBadge(status: item['verificationStatus']),
                                  StatusBadge(status: item['listingStatus']),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'অবস্থান: ${item['areaName']}, ${item['upazila']}, ${item['district']} • মৌজা: ${item['mouzaName'] ?? 'N/A'}',
                      style: const TextStyle(fontSize: 12.5, color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'পরিমাণ: ${item['areaDecimal']} শতাংশ • মূল্য: ৳${item['expectedPriceBdt']}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0B4F32)),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => onEditListing(item),
                          icon: const Icon(Icons.edit_outlined, size: 15),
                          label: const Text('সম্পাদনা (Edit)', style: TextStyle(fontSize: 11)),
                        ),
                        if (hasDoc)
                          OutlinedButton.icon(
                            onPressed: () => onPreviewDoc(item),
                            icon: const Icon(Icons.description_outlined, size: 15),
                            label: const Text('সংযুক্ত দলিল দেখুন', style: TextStyle(fontSize: 11)),
                          ),
                        if (!isSold)
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.red.shade700),
                            onPressed: () => onMarkSold(item['id'] as int),
                            icon: const Icon(Icons.lock_outline, size: 15),
                            label: const Text('বিক্রি সম্পন্ন (SOLD)', style: TextStyle(fontSize: 11)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}
