import 'package:flutter/material.dart';
import 'package:landtrust_app/core/animations/legal_verification_animations.dart';
import 'package:landtrust_app/core/widgets/smart_image_viewer.dart';

class PrivateDocumentPreviewDialog extends StatelessWidget {
  final Map<String, dynamic> listing;
  final bool isMobile;

  const PrivateDocumentPreviewDialog({super.key, required this.listing, required this.isMobile});

  static void show(
    BuildContext context, {
    required Map<String, dynamic> listing,
    required bool isMobile,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => PrivateDocumentPreviewDialog(listing: listing, isMobile: isMobile),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: 16),
      title: Row(children: [
        const Icon(Icons.document_scanner, color: Color(0xFF0B4F32), size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text('সংযুক্ত খতিয়ান / দলিলের কপি (${listing['title']})', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
        ),
      ]),
      content: SizedBox(
        width: isMobile ? null : 600,
        child: Stack(alignment: Alignment.topCenter, children: [
          SmartImageViewer(
            url: listing['privateDocumentUrl'] as String?,
            height: isMobile ? 260 : 380,
            width: isMobile ? 280 : 580,
            enableZoom: true,
          ),
          const Positioned(top: 8, child: DocumentScannerLaser()),
        ]),
      ),
      actionsAlignment: MainAxisAlignment.end,
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('বন্ধ করুন')),
      ],
    );
  }
}
