import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CsvExportDialog {
  static void show(BuildContext context, {required String title, required String content}) {
    showDialog(
      context: context,
      builder: (ctx) {
        final isMobile = MediaQuery.of(ctx).size.width < 600;
        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: 16),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: SizedBox(
            width: isMobile ? double.infinity : 620,
            child: SingleChildScrollView(
              child: SelectableText(
                content,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('বন্ধ করুন'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B4F32),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: content));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('ক্লিপবোর্ডে কপি হয়েছে! এখন Excel বা টেক্সট ফাইলে পেস্ট করতে পারবেন।'),
                  ),
                );
              },
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('কপি করুন (Copy)'),
            ),
          ],
        );
      },
    );
  }
}
