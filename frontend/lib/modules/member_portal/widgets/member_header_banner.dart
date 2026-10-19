import 'package:flutter/material.dart';
import 'package:landtrust_app/core/widgets/status_badge.dart';

class MemberHeaderBanner extends StatelessWidget {
  final Map<String, dynamic> user;
  final bool isMobile;
  final int unreadCount;
  final VoidCallback onProfileClick;
  final VoidCallback onNotificationsClick;
  final VoidCallback onRefresh;
  final VoidCallback onResubmitPaymentClick;

  const MemberHeaderBanner({
    super.key,
    required this.user,
    required this.isMobile,
    required this.unreadCount,
    required this.onProfileClick,
    required this.onNotificationsClick,
    required this.onRefresh,
    required this.onResubmitPaymentClick,
  });

  String _roleBangla(String role) {
    return switch (role) {
      'ADMIN' => 'প্রধান পরিচালক (Admin)',
      'MARKETING_OFFICER' => 'মার্কেটিং অফিসার',
      'SELLER' => 'জমির বিক্রেতা (Seller)',
      _ => 'জমির ক্রেতা (Buyer)',
    };
  }

  @override
  Widget build(BuildContext context) {
    final status = user['accountStatus'] as String? ?? 'PAYMENT_SUBMITTED';
    final role = user['role'] as String? ?? 'BUYER';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(isMobile ? 14 : 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF0B4F32), Color(0xFF146C43)]),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_user, color: Colors.amberAccent, size: 24),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            user['fullName'] ?? '',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isMobile ? 18 : 22,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(status: status),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'ভূমিকা: ${_roleBangla(role)} • মোবাইল: ${user['phoneNumber']} • ${user['upazila'] ?? 'নোয়াখালী সদর'}',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              if (user['referredByCode'] != null) ...[
                const SizedBox(height: 4),
                Text(
                  'রেফারেল কোড: ${user['referredByCode']} (${user['referredByOfficerName'] ?? ''})',
                  style: const TextStyle(color: Colors.amberAccent, fontSize: 12),
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white24,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onPressed: onProfileClick,
                    icon: const Icon(Icons.manage_accounts_outlined, size: 16),
                    label: const Text('প্রোফাইল ও পাসওয়ার্ড', style: TextStyle(fontSize: 12)),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: unreadCount > 0 ? Colors.amber.shade600 : Colors.white24,
                      foregroundColor: unreadCount > 0 ? Colors.black : Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onPressed: onNotificationsClick,
                    icon: Badge(
                      isLabelVisible: unreadCount > 0,
                      label: Text('$unreadCount'),
                      child: const Icon(Icons.notifications_active_outlined, size: 16),
                    ),
                    label: Text('নোটিফিকেশন ($unreadCount)', style: const TextStyle(fontSize: 12)),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0B4F32),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onPressed: onRefresh,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('রিফ্রেশ', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (status != 'ACTIVE') ...[
          const SizedBox(height: 10),
          _buildPaymentWarning(status),
        ],
      ],
    );
  }

  Widget _buildPaymentWarning(String status) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: status == 'REJECTED' ? Colors.red.shade50 : Colors.amber.shade50,
        border: Border.all(color: status == 'REJECTED' ? Colors.red.shade400 : Colors.amber.shade600),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                status == 'REJECTED' ? Icons.error_outline : Icons.info_outline,
                color: status == 'REJECTED' ? Colors.red.shade700 : Colors.orange.shade800,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  status == 'REJECTED'
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
