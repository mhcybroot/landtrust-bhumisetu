import 'package:flutter/material.dart';

class ChatMessageBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool isFromCurrentUser;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isFromCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    final text = message['text']?.toString() ?? '';
    final sender = message['senderName']?.toString() ?? '';
    final time = _formatTime(message['createdAt']?.toString());

    return Align(
      alignment: isFromCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
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
          boxShadow: [
            BoxStyles.shadow,
          ],
        ),
        child: Column(
          crossAxisAlignment: isFromCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isFromCurrentUser)
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
            Text(
              time,
              style: TextStyle(
                color: isFromCurrentUser ? Colors.white70 : Colors.black45,
                fontSize: 9.5,
              ),
            ),
          ],
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
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      return '$h:$m $period';
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
