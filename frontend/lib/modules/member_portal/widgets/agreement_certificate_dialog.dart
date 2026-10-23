import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:landtrust_app/core/animations/legal_verification_animations.dart';

class AgreementCertificateDialog extends StatelessWidget {
  final Map<String, dynamic> proposal;
  final bool isMobile;

  const AgreementCertificateDialog({super.key, required this.proposal, required this.isMobile});

  static void show(BuildContext context, {required Map<String, dynamic> proposal, required bool isMobile}) {
    showDialog(context: context, builder: (ctx) => AgreementCertificateDialog(proposal: proposal, isMobile: isMobile));
  }

  @override
  Widget build(BuildContext context) {
    final certText = '''
=============================================================
         bdHousing — বিশেষ সেবা চুক্তিপত্র সনদ
=============================================================
সনদ নম্বর: LT-AGR-${proposal['id']}
তারিখ: ${proposal['agreedAt'] ?? proposal['updatedAt'] ?? '২০২৬'}

গ্রাহক / সদস্য: ${proposal['userName'] ?? proposal['customerName'] ?? 'সদস্য'}
ভূমিকা: ${proposal['userRole'] ?? proposal['customerRole'] ?? 'গ্রাহক'}
প্রস্তাব শিরোনাম: ${proposal['proposalTitle']}
কাজের বিবরণ: ${proposal['scopeDescription']}

চূড়ান্ত পারস্পরিক সম্মত ফি: ৳${proposal['finalAgreedFeeBdt'] ?? proposal['customerProposedFeeBdt']}
স্ট্যাটাস: ${proposal['status']}
=============================================================
শর্তাবলী: উভয় পক্ষের সম্মতি ছাড়া কোনো অতিরিক্ত বা গোপন চার্জ প্রযোজ্য নয়।
''';

    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: 16),
      title: Row(children: [
        const DeedRibbonUnfurl(),
        const SizedBox(width: 8),
        Expanded(child: Text('বিশেষ সেবা চুক্তিপত্র সনদ (LT-AGR-${proposal['id']})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
        const SizedBox(width: 6),
        const TrustSealStamp(size: 32),
      ]),
      content: SizedBox(
        width: isMobile ? null : 600,
        child: SingleChildScrollView(
          child: SelectableText(certText, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('বন্ধ করুন')),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: certText));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('চুক্তিপত্র সনদ কপি হয়েছে!')));
          },
          icon: const Icon(Icons.copy, size: 16),
          label: const Text('কপি করুন (Copy)'),
        ),
      ],
    );
  }
}
