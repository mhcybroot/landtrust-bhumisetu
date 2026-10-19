import 'package:flutter/material.dart';

class MemberNotificationsDialog {
  static void show(
    BuildContext context, {
    required Map<String, dynamic> notificationsData,
    required bool isMobile,
    required Future<void> Function(int) onMarkRead,
  }) {
    final list = (notificationsData['notifications'] as List<dynamic>?) ?? [];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: 16),
        title: Text('নোটিফিকেশনসমূহ (${list.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: SizedBox(
          width: isMobile ? double.infinity : 500,
          child: list.isEmpty
              ? const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('কোনো নতুন নোটিফিকেশন নেই।')))
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, idx) {
                    final n = list[idx] as Map<String, dynamic>;
                    final isRead = n['isRead'] == true;
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
                          : IconButton(
                              icon: const Icon(Icons.check, size: 16, color: Colors.green),
                              tooltip: 'পঠিত হিসেবে চিহ্নিত করুন',
                              onPressed: () async {
                                await onMarkRead(n['id'] as int);
                                if (context.mounted) Navigator.pop(ctx);
                              },
                            ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বন্ধ করুন')),
        ],
      ),
    );
  }
}
