import 'package:flutter/material.dart';
import 'package:landtrust_app/core/animations/bouncing_pressable.dart';
import 'package:landtrust_app/core/animations/transitions/state_micro_transitions.dart';

class MemberNotificationsDialog {
  static void show(
    BuildContext context, {
    required Map<String, dynamic> notificationsData,
    required bool isMobile,
    required Future<void> Function(int) onMarkRead,
    Future<void> Function()? onMarkAllRead,
  }) {
    final list = (notificationsData['notifications'] as List<dynamic>?) ?? [];
    final unreadCount = (notificationsData['unreadCount'] as num?)?.toInt() ?? 0;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: 16),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('নোটিফিকেশনসমূহ (${list.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            BadgeCountPopTransition(count: unreadCount),
          ],
        ),
        content: SizedBox(
          width: isMobile ? double.infinity : 500,
          child: list.isEmpty
              ? const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('কোনো নোটিফিকেশন নেই।')))
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, idx) {
                    final n = list[idx] as Map<String, dynamic>;
                    final isRead = n['readStatus'] == true || n['isRead'] == true;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        isRead ? Icons.notifications_none : Icons.notifications_active,
                        color: isRead ? Colors.grey : const Color(0xFF0B4F32),
                      ),
                      title: Text(n['title'] ?? '', style: TextStyle(fontWeight: isRead ? FontWeight.normal : FontWeight.bold, fontSize: 13)),
                      subtitle: Text(n['message'] ?? '', style: const TextStyle(fontSize: 11)),
                      trailing: isRead
                          ? null
                          : BouncingPressable(
                              onTap: () async {
                                await onMarkRead(n['id'] as int);
                                if (context.mounted) Navigator.pop(ctx);
                              },
                              child: IconButton(
                                icon: const Icon(Icons.check, size: 16, color: Colors.green),
                                tooltip: 'পঠিত হিসেবে চিহ্নিত করুন',
                                onPressed: () async {
                                  await onMarkRead(n['id'] as int);
                                  if (context.mounted) Navigator.pop(ctx);
                                },
                              ),
                            ),
                    );
                  },
                ),
        ),
        actions: [
          if (unreadCount > 0 && onMarkAllRead != null)
            BouncingPressable(
              onTap: () async {
                await onMarkAllRead();
                if (context.mounted) Navigator.pop(ctx);
              },
              child: TextButton.icon(
                icon: const Icon(Icons.done_all, size: 16),
                label: const Text('সব পঠিত করুন'),
                onPressed: () async {
                  await onMarkAllRead();
                  if (context.mounted) Navigator.pop(ctx);
                },
              ),
            ),
          BouncingPressable(
            onTap: () => Navigator.pop(ctx),
            child: TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বন্ধ করুন')),
          ),
        ],
      ),
    );
  }
}
