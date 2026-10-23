import 'package:flutter/material.dart';
import '../../../core/animations/bouncing_pressable.dart';
import '../../../core/animations/field_visit_animations.dart';

class ChatMessageBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool isFromCurrentUser;

  const ChatMessageBubble({
    super.key,
    required this.message,
    bool? isMe,
    bool? isFromCurrentUser,
  }) : isFromCurrentUser = isFromCurrentUser ?? isMe ?? false;

  @override
  Widget build(BuildContext context) {
    final text = message['text']?.toString() ?? message['content']?.toString() ?? '';
    final sender = message['senderName']?.toString() ?? '';
    final time = _formatTime(message['createdAt']?.toString());
    final isRead = message['isRead'] == true;

    return Align(
      alignment: isFromCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: BouncingPressable(
        scaleFactor: 0.98,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isFromCurrentUser ? const Color(0xFF0B4F32) : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(14),
              topRight: const Radius.circular(14),
              bottomLeft: Radius.circular(isFromCurrentUser ? 14 : 2),
              bottomRight: Radius.circular(isFromCurrentUser ? 2 : 14),
            ),
            boxShadow: const [BoxStyles.shadow],
          ),
          child: Column(
            crossAxisAlignment: isFromCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isFromCurrentUser && sender.isNotEmpty)
                Text(
                  sender,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF0B4F32)),
                ),
              Text(
                text,
                style: TextStyle(
                  color: isFromCurrentUser ? Colors.white : Colors.black87,
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    time,
                    style: TextStyle(
                      color: isFromCurrentUser ? Colors.white70 : Colors.black45,
                      fontSize: 9.5,
                    ),
                  ),
                  if (isFromCurrentUser) ...[
                    const SizedBox(width: 4),
                    ReadReceiptCheckMorph(isRead: isRead),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m ${dt.hour >= 12 ? 'PM' : 'AM'}';
    } catch (_) {
      return '';
    }
  }
}

class BoxStyles {
  static const shadow = BoxShadow(
    color: Color(0x12000000),
    blurRadius: 3,
    offset: Offset(0, 1),
  );
}
