import 'package:flutter/material.dart';
import '../../../core/animations/bouncing_pressable.dart';
import '../../../core/animations/transitions/route_navigation_transitions.dart';
import '../../../core/animations/transitions/state_micro_transitions.dart';
import '../../../core/session/session_manager.dart';
import '../repositories/chat_repository.dart';
import '../view_models/chat_view_model.dart';
import 'chat_conversation_screen.dart';

class MyChatThreadsDialog extends StatelessWidget {
  final bool isMobile;
  final ChatViewModel? viewModel;
  final List<dynamic>? threads;
  final int? listingId;
  final String? listingTitle;

  const MyChatThreadsDialog({
    super.key,
    required this.isMobile,
    this.viewModel,
    this.threads,
    this.listingId,
    this.listingTitle,
  });

  static void show(BuildContext context, {required bool isMobile, int? listingId, String? listingTitle}) {
    final vm = ChatViewModel();
    if (SessionManager.instance.isLoggedIn) vm.loadMyThreads();
    showDialog(
      context: context,
      builder: (_) => MyChatThreadsDialog(isMobile: isMobile, viewModel: vm, listingId: listingId, listingTitle: listingTitle),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = viewModel;
    final loggedIn = SessionManager.instance.isLoggedIn || threads != null;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: isMobile ? double.infinity : 480,
        height: 480,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('লাইভ সাপোর্ট ও ইনবক্স', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                if (loggedIn)
                  BouncingPressable(
                    child: IconButton(
                      icon: const Icon(Icons.add_comment, color: Color(0xFF0B4F32)),
                      tooltip: 'নতুন মেসেজ শুরু করুন',
                      onPressed: () => _showNewThreadDialog(context, vm, isMobile, listingId: listingId, listingTitle: listingTitle),
                    ),
                  ),
              ],
            ),
            const Divider(),
            Expanded(
              child: !loggedIn
                  ? _buildGuestView(context)
                  : vm != null
                      ? ListenableBuilder(listenable: vm, builder: (ctx, _) => _buildList(ctx, vm.threads, vm.isLoading, vm))
                      : _buildList(context, threads ?? const [], false, null),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: BouncingPressable(
                child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('বন্ধ করুন')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestView(BuildContext ctx) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_person_outlined, size: 44, color: Color(0xFF0B4F32)),
          const SizedBox(height: 8),
          const Text('লাইভ সাপোর্ট পেতে লগইন করুন', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          const Text('সাপোর্ট টিমের সাথে চ্যাট করতে অ্যাকাউন্টে লগইন আবশ্যক।', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 12),
          BouncingPressable(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
              onPressed: () => Navigator.pop(ctx),
              icon: const Icon(Icons.check, size: 16),
              label: const Text('ঠিক আছে'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext ctx, List<dynamic> list, bool loading, ChatViewModel? vm) {
    if (loading && list.isEmpty) return const Center(child: CircularProgressIndicator());
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 10),
            const Text('কোনো সক্রিয় বার্তা নেই'),
            const SizedBox(height: 12),
            BouncingPressable(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
                onPressed: () => _showNewThreadDialog(ctx, vm, isMobile, listingId: listingId, listingTitle: listingTitle),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('মেসেজ পাঠান'),
              ),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (c, i) {
        final t = list[i] as Map<String, dynamic>;
        final unread = (t['unreadUserCount'] as num?)?.toInt() ?? 0;
        return BouncingPressable(
          scaleFactor: 0.99,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF0B4F32).withValues(alpha: 0.12),
              child: const Icon(Icons.support_agent, color: Color(0xFF0B4F32)),
            ),
            title: Text(t['subject'] ?? 'সহায়তা', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
            subtitle: Text(t['lastMessage'] ?? 'বার্তা নেই', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
            trailing: unread > 0 ? BadgeCountPopTransition(count: unread) : const Icon(Icons.chevron_right, size: 18),
            onTap: vm == null ? null : () {
              Navigator.pop(ctx);
              Navigator.push(ctx, SharedAxisSlideRoute(page: ChatConversationScreen(viewModel: vm, thread: t, isAdmin: false)));
            },
          ),
        );
      },
    );
  }

  static void _showNewThreadDialog(BuildContext context, ChatViewModel? vm, bool isMobile, {int? listingId, String? listingTitle}) {
    final subCtrl = TextEditingController(text: listingTitle != null ? 'জমি সংক্রান্ত: $listingTitle' : 'সহায়তা ও তথ্য');
    final msgCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('নতুন মেসেজ শুরু করুন', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: subCtrl, decoration: const InputDecoration(labelText: 'বিষয় (Subject)', isDense: true)),
          const SizedBox(height: 10),
          TextField(controller: msgCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'আপনার বার্তা লিখুন', isDense: true)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
          BouncingPressable(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
              onPressed: () async {
                final sub = subCtrl.text.trim();
                final msg = msgCtrl.text.trim();
                if (msg.isEmpty) return;
                Navigator.pop(ctx);
                final res = await ChatRepository().startThread(subject: sub, listingId: listingId, initialMessage: msg);
                if (context.mounted) {
                  if (res.isNotEmpty && vm != null) {
                    Navigator.push(context, SharedAxisSlideRoute(page: ChatConversationScreen(viewModel: vm, thread: res, isAdmin: false)));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('বার্তা শুরু করা যায়নি। নেটওয়ার্ক বা সার্ভার চেক করুন।')));
                  }
                }
              },
              child: const Text('পাঠান'),
            ),
          ),
        ],
      ),
    );
  }
}
