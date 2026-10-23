import 'package:flutter/material.dart';
import 'package:landtrust_app/core/animations/bouncing_pressable.dart';
import 'package:landtrust_app/core/widgets/status_badge.dart';
import '../../chat/views/my_chat_threads_dialog.dart';
import '../../nrb/widgets/my_nrb_requests_dialog.dart';
import 'member_payment_warning_card.dart';

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

  String _roleBangla(String role) => switch (role) {
    'ADMIN' => 'প্রধান পরিচালক (Admin)',
    'MARKETING_OFFICER' => 'মার্কেটিং অফিসার',
    'SELLER' => 'জমির বিক্রেতা (Seller)',
    _ => 'জমির ক্রেতা (Buyer)',
  };

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
                            style: TextStyle(color: Colors.white, fontSize: isMobile ? 18 : 22, fontWeight: FontWeight.bold),
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
                  BouncingPressable(
                    onTap: onProfileClick,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white24, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                      onPressed: onProfileClick,
                      icon: const Icon(Icons.manage_accounts_outlined, size: 16),
                      label: const Text('প্রোফাইল ও পাসওয়ার্ড', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  BouncingPressable(
                    onTap: onNotificationsClick,
                    child: ElevatedButton.icon(
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
                  ),
                  BouncingPressable(
                    onTap: () => MyChatThreadsDialog.show(context, isMobile: isMobile),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white24, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                      onPressed: () => MyChatThreadsDialog.show(context, isMobile: isMobile),
                      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                      label: const Text('লাইভ চ্যাট', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  BouncingPressable(
                    onTap: () => MyNrbRequestsDialog.show(context, isMobile: isMobile),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE8F5E9), foregroundColor: const Color(0xFF0B4F32), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                      onPressed: () => MyNrbRequestsDialog.show(context, isMobile: isMobile),
                      icon: const Icon(Icons.flight_takeoff, size: 16, color: Color(0xFF0B4F32)),
                      label: const Text('প্রবাসী সেবা ও PoA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  BouncingPressable(
                    onTap: onRefresh,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF0B4F32), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                      onPressed: onRefresh,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('রিফ্রেশ', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (status != 'ACTIVE') ...[
          const SizedBox(height: 10),
          MemberPaymentWarningCard(user: user, onResubmitPaymentClick: onResubmitPaymentClick),
        ],
      ],
    );
  }
}
