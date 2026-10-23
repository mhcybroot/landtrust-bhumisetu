import 'package:flutter/material.dart';
import '../../../core/animations/transitions/route_navigation_transitions.dart';
import '../../chat/view_models/chat_view_model.dart';
import '../../chat/views/chat_conversation_screen.dart';

class AdminChatInboxTab extends StatefulWidget {
  final bool isMobile;

  const AdminChatInboxTab({super.key, required this.isMobile});

  @override
  State<AdminChatInboxTab> createState() => _AdminChatInboxTabState();
}

class _AdminChatInboxTabState extends State<AdminChatInboxTab> {
  late final ChatViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = ChatViewModel();
    _vm.loadAdminThreads();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'সাপোর্ট ইনবক্স (লাইভ মেসেজিং)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Color(0xFF0B4F32)),
              tooltip: 'রিফ্রেশ করুন',
              onPressed: () => _vm.loadAdminThreads(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListenableBuilder(
          listenable: _vm,
          builder: (ctx, _) {
            if (_vm.isLoading && _vm.threads.isEmpty) {
              return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
            }
            if (_vm.threads.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text('কোনো সক্রিয় মেসেজ বা ইনকোয়ারি নেই।')),
                ),
              );
            }
            return Column(
              children: _vm.threads.map((t) {
                final thread = t as Map<String, dynamic>;
                final unread = (thread['unreadAdminCount'] as num?)?.toInt() ?? 0;
                final status = thread['status']?.toString() ?? 'OPEN';

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(widget.isMobile ? 10 : 14),
                    leading: CircleAvatar(
                      backgroundColor: unread > 0 ? Colors.red.shade100 : const Color(0xFF0B4F32).withValues(alpha: 0.1),
                      child: Icon(
                        unread > 0 ? Icons.mark_chat_unread : Icons.chat_outlined,
                        color: unread > 0 ? Colors.red : const Color(0xFF0B4F32),
                      ),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${thread['userName']} (${thread['userRole']})',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        if (unread > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                            child: Text('$unread নতুন', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        Text('বিষয়: ${thread['subject']}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
                        const SizedBox(height: 2),
                        Text('মোবাইল: ${thread['userPhone']} • স্ট্যাটাস: $status', style: const TextStyle(fontSize: 11)),
                        const SizedBox(height: 4),
                        Text('সর্বশেষ বার্তা: ${thread['lastMessage'] ?? '-'}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, color: Colors.black54)),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        SharedAxisSlideRoute(page: ChatConversationScreen(viewModel: _vm, thread: thread, isAdmin: true)),
                      );
                      _vm.loadAdminThreads();
                    },
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
