import 'package:flutter/material.dart';
import '../../../core/animations/bouncing_pressable.dart';
import '../../../core/animations/delight_financial_animations.dart';
import '../view_models/chat_view_model.dart';
import '../widgets/chat_message_bubble.dart';

class ChatConversationScreen extends StatefulWidget {
  final ChatViewModel viewModel;
  final Map<String, dynamic> thread;
  final bool isAdmin;

  const ChatConversationScreen({
    super.key,
    required this.viewModel,
    required this.thread,
    this.isAdmin = false,
  });

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    final threadId = widget.thread['id'] as int;
    widget.viewModel.openThread(threadId, isAdmin: widget.isAdmin).then((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _handleSend() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    final success = widget.isAdmin ? await widget.viewModel.adminReply(text) : await widget.viewModel.sendMessage(text);
    if (mounted) {
      setState(() => _sending = false);
      if (success) {
        _inputCtrl.clear();
        _scrollToBottom();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('বার্তা পাঠানো যায়নি। নেটওয়ার্ক বা সার্ভার চেক করুন।')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.thread['subject']?.toString() ?? 'সহায়তা চ্যাট';
    final otherName = widget.isAdmin ? (widget.thread['userName']?.toString() ?? 'ইউজার') : 'সাপোর্ট অফিসার';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B4F32),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            Text(otherName, style: const TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
      ),
      body: Container(
        color: const Color(0xFFECE5DD).withValues(alpha: 0.4),
        child: Column(
          children: [
            Expanded(
              child: ListenableBuilder(
                listenable: widget.viewModel,
                builder: (ctx, _) {
                  if (widget.viewModel.isLoading && widget.viewModel.activeMessages.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final msgs = widget.viewModel.activeMessages;
                  if (msgs.isEmpty) {
                    return const Center(child: Text('কোনো পূর্ববর্তী বার্তা নেই। আপনার বার্তা লিখুন।'));
                  }
                  return ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: msgs.length,
                    itemBuilder: (ctx, i) {
                      final m = msgs[i] as Map<String, dynamic>;
                      final role = m['senderRole']?.toString() ?? '';
                      final isMe = widget.isAdmin ? role == 'ADMIN' : role == 'USER';
                      final bubble = ChatMessageBubble(message: m, isFromCurrentUser: isMe);
                      return i == msgs.length - 1 ? MessageFlightCurve(child: bubble) : bubble;
                    },
                  );
                },
              ),
            ),
            if (_sending)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Align(alignment: Alignment.centerLeft, child: ChatTypingWave()),
              ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      color: Colors.white,
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _inputCtrl,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: widget.isAdmin ? 'ইউজারকে রিপ্লাই দিন...' : 'আপনার বার্তা লিখুন...',
                  filled: true,
                  fillColor: const Color(0xFFF0F2F5),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  isDense: true,
                ),
                onSubmitted: (_) => _handleSend(),
              ),
            ),
            const SizedBox(width: 6),
            BouncingPressable(
              child: IconButton.filled(
                style: IconButton.styleFrom(backgroundColor: const Color(0xFF0B4F32)),
                icon: _sending
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                onPressed: _sending ? null : _handleSend,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
