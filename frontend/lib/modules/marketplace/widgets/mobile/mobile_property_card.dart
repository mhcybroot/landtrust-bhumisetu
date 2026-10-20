import 'package:flutter/material.dart';
import 'package:landtrust_app/core/widgets/smart_image_viewer.dart';

class MobilePropertyCard extends StatelessWidget {
  final Map<String, dynamic> listing;
  final VoidCallback onDetailsClick;
  final VoidCallback onInquiryClick;

  const MobilePropertyCard({
    super.key,
    required this.listing,
    required this.onDetailsClick,
    required this.onInquiryClick,
  });

  @override
  Widget build(BuildContext context) {
    final title = listing['title']?.toString() ?? 'নামবিহীন জমি';
    final district = listing['district']?.toString() ?? 'নোয়াখালী';
    final upazila = listing['upazila']?.toString() ?? '';
    final area = listing['areaDecimals']?.toString() ?? '০';
    final price = listing['expectedPrice']?.toString() ?? '০';
    final landType = listing['landType']?.toString() ?? 'জমি';
    final status = listing['status']?.toString() ?? 'APPROVED';
    final photoUrl = listing['primaryPhotoUrl']?.toString();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onDetailsClick,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: SmartImageViewer(url: photoUrl),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      landType,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                if (status == 'APPROVED')
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B4F32),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, color: Colors.amber, size: 12),
                          SizedBox(width: 4),
                          Text('যাচাইকৃত', style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, height: 1.25),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 15, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '$upazila, $district',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1, thickness: 0.8),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('জমির পরিমাণ: $area শতক', style: TextStyle(fontSize: 12, color: Colors.grey.shade800, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(
                            '৳$price',
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0B4F32)),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: onInquiryClick,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B4F32),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          visualDensity: VisualDensity.compact,
                        ),
                        icon: const Icon(Icons.send_rounded, size: 14),
                        label: const Text('যোগাযোগ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
}
