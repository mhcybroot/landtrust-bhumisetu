import 'package:flutter/material.dart';

class MemberPaymentWarningCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onResubmitPaymentClick;

  const MemberPaymentWarningCard({
    super.key,
    required this.user,
    required this.onResubmitPaymentClick,
  });

  @override
  Widget build(BuildContext context) {
    final status = user['accountStatus'] as String? ?? 'PAYMENT_SUBMITTED';
    final isRejected = status == 'REJECTED';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isRejected ? Colors.red.shade50 : Colors.amber.shade50,
        border: Border.all(color: isRejected ? Colors.red.shade400 : Colors.amber.shade600),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isRejected ? Icons.error_outline : Icons.info_outline,
                color: isRejected ? Colors.red.shade700 : Colors.orange.shade800,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isRejected
                      ? 'পেমেন্ট তথ্য (TrxID: ${user['transactionId']}) মেলেনি বা বাতিল হয়েছে।'
                      : 'নিবন্ধন ফি (৳${user['registrationFeeAmount']}) ও TrxID (${user['transactionId']}) যাচাই চলছে।',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          if (user['adminNote'] != null && user['adminNote'].toString().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('নোট: ${user['adminNote']}', style: TextStyle(color: Colors.red.shade900, fontSize: 12)),
          ],
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B4F32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onPressed: onResubmitPaymentClick,
              icon: const Icon(Icons.edit_note, size: 16),
              label: const Text('সঠিক TrxID পুনরায় জমা দিন', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}
