import 'package:flutter/material.dart';
import '../utils/whatsapp_helper.dart';

class AccountStatusLockDialog extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback? onResubmitRequested;

  const AccountStatusLockDialog({
    super.key,
    required this.user,
    this.onResubmitRequested,
  });

  static Future<void> show(
    BuildContext context, {
    required Map<String, dynamic> user,
    VoidCallback? onResubmitRequested,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AccountStatusLockDialog(
        user: user,
        onResubmitRequested: onResubmitRequested,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = (user['accountStatus'] ?? 'PENDING').toString().toUpperCase();
    final isRejected = status == 'REJECTED';
    final isSuspended = status == 'SUSPENDED';
    final trxId = (user['transactionId']?.toString().isNotEmpty == true)
        ? user['transactionId']
        : 'জমাকৃত নয়';

    final Color primaryColor = isRejected || isSuspended
        ? const Color(0xFFC62828)
        : const Color(0xFFE65100);
    final IconData iconData = isSuspended
        ? Icons.block_rounded
        : (isRejected ? Icons.error_outline_rounded : Icons.pending_actions_rounded);

    final String title = isSuspended
        ? 'অ্যাকাউন্ট স্থগিত রয়েছে'
        : (isRejected
            ? 'পেমেন্ট যাচাই বাতিল হয়েছে'
            : 'অ্যাকাউন্ট ভেরিফিকেশন অপেক্ষমাণ');

    final String message = isSuspended
        ? 'আপনার অ্যাকাউন্টটি স্থগিত অবস্থায় আছে। বিস্তারিত জানতে ভূমি সেতু সাপোর্টে যোগাযোগ করুন।'
        : (isRejected
            ? 'আপনার সদস্য ফি TrxID ($trxId) যাচাই ব্যর্থ হয়েছে। অনুগ্রহ করে সঠিক TrxID ও প্রেরক নম্বর পুনরায় জমা দিন।'
            : 'আপনার সদস্য ফি বাবদ জমা দেওয়া TrxID ($trxId) অ্যাডমিন যাচাই করছেন। অনুমোদন সম্পন্ন হলেই আপনি বিজ্ঞাপন বা চাহিদা প্রকাশ করতে পারবেন।');

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: primaryColor, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: const TextStyle(fontSize: 13.5, height: 1.4)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_long, size: 18, color: Colors.blueGrey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'বর্তমান TrxID: $trxId',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        OutlinedButton.icon(
          icon: const Icon(Icons.chat_bubble_outline, size: 16, color: Color(0xFF25D366)),
          label: const Text('WhatsApp সাপোর্ট', style: TextStyle(fontSize: 12.5, color: Color(0xFF075E54))),
          onPressed: () {
            Navigator.pop(context);
            WhatsAppHelper.openChat(
              phone: '01886178306',
              message: 'আসসালামু আলাইকুম। আমার ভূমি সেতু অ্যাকাউন্টের স্ট্যাটাস ($status) ও পেমেন্ট TrxID ($trxId) সংক্রান্ত তথ্য জানতে চাই।',
            );
          },
        ),
        if (!isSuspended && onResubmitRequested != null)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0B4F32),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              onResubmitRequested!();
            },
            child: const Text('TrxID সংশোধন', style: TextStyle(fontSize: 13)),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ঠিক আছে'),
        ),
      ],
    );
  }
}
