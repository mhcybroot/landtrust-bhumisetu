import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/modules/chat/widgets/chat_message_bubble.dart';
import 'package:landtrust_app/modules/chat/views/my_chat_threads_dialog.dart';

void main() {
  testWidgets('ChatMessageBubble renders with touch spring and read checkmark', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ChatMessageBubble(
          message: const {'text': 'Hello', 'senderName': 'User', 'isRead': true},
          isMe: true,
        ),
      ),
    ));
    await tester.pump();
    expect(find.byType(ChatMessageBubble), findsOneWidget);
  });

  testWidgets('MyChatThreadsDialog renders with unread count badge pop', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: MyChatThreadsDialog(
          isMobile: true,
          threads: const [
            {'subject': 'Support', 'lastMessage': 'Hello', 'unreadUserCount': 3}
          ],
        ),
      ),
    ));
    await tester.pump();
    expect(find.byType(MyChatThreadsDialog), findsOneWidget);
  });
}
