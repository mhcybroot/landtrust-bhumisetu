import 'package:flutter/material.dart';
import 'package:landtrust_app/core/widgets/smart_image_viewer.dart';

class PrivateDocumentPreviewDialog {
  static void show(
    BuildContext context, {
    required Map<String, dynamic> listing,
    required bool isMobile,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'সংযুক্ত খতিয়ান / দলিলের কপি (${listing['title']})',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: isMobile ? double.infinity : 600,
          child: SmartImageViewer(
            url: listing['privateDocumentUrl'] as String?,
            height: isMobile ? 260 : 380,
            width: double.infinity,
            enableZoom: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('বন্ধ করুন'),
          ),
        ],
      ),
    );
  }
}
