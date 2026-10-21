import 'package:flutter/material.dart';
import '../repositories/chat_repository.dart';
import '../view_models/chat_view_model.dart';
import 'chat_conversation_screen.dart';

class MyChatThreadsDialog {
  static void show(
    BuildContext context, {
    required bool isMobile,
    int? listingId,
    String? listingTitle,
  }) {
    final vm = ChatViewModel();
    vm.loadMyThreads();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: 16),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('লাইভ সাপোর্ট ও ইনবক্স', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            IconButton(
              icon: const Icon(Icons.add_comment, color: Color(0xFF0B4F32)),
              tooltip: 'নতুন মেসেজ শুরু করুন',
              onPressed: () => _showNewThreadDialog(context, vm, isMobile, listingId: listingId, listingTitle: listingTitle),
            ),
          ],
        ),
        content: SizedBox(
          width: isMobile ? double.infinity : 480,
          height: 400,
          child: ListenableBuilder(
            listenable: vm,
            builder: (ctx, _) {
              if (vm.isLoading && vm.threads.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (vm.threads.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey),
                      const SizedBox(height: 10),
                      const Text('কোনো সক্রিয় বার্তা নেই'),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
                        onPressed: () => _showNewThreadDialog(context, vm, isMobile, listingId: listingId, listingTitle: listingTitle),
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('মেসেজ পাঠান'),
                      ),
                    ],
                  ),
                );
              }
              return ListView.separated(
                itemCount: vm.threads.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final t = vm.threads[i] as Map<String, dynamic>;
                  final unread = (t['unreadUserCount'] as num?)?.toInt() ?? 0;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF0B4F32).withOpacity(0.12),
                      child: const Icon(Icons.support_agent, color: Color(0xFF0B4F32)),
                    ),
                    title: Text(t['subject'] ?? 'সহায়তা', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                    subtitle: Text(t['lastMessage'] ?? 'বার্তা নেই', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                    trailing: unread > 0
                        ? Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          )
                        : const Icon(Icons.chevron_right, size: 18),
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ChatConversationScreen(viewModel: vm, thread: t, isAdmin: false)));
                    },
                  );
                },
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

  static void _showNewThreadDialog(
    BuildContext context,
    ChatViewModel vm,
    bool isMobile, {
    int? listingId,
    String? listingTitle,
  }) {
    final subCtrl = TextEditingController(text: listingTitle != null ? 'জমি সংক্রান্ত: $listingTitle' : 'সহায়তা ও তথ্য');
    final msgCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('নতুন মেসেজ শুরু করুন', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: subCtrl, decoration: const InputDecoration(labelText: 'বিষয় (Subject)', isDense: true)),
            const SizedBox(height: 10),
            TextField(controller: msgCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'আপনার বার্তা লিখুন', isDense: true)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
            onPressed: () async {
              final sub = subCtrl.text.trim();
              final msg = msgCtrl.text.trim();
              if (msg.isEmpty) return;
              Navigator.pop(ctx);
              final res = await ChatRepository().startThread(subject: sub, listingId: listingId, initialMessage: msg);
              if (res.isNotEmpty && context.mounted) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ChatConversationScreen(viewModel: vm, thread: res, isAdmin: false)));
              }
            },
            child: const Text('পাঠান'),
          ),
        ],
      ),
    );
  }
}
