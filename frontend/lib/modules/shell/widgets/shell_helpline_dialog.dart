import 'package:flutter/material.dart';
import '../../../../core/utils/whatsapp_helper.dart';

class ShellHelplineDialog {
  static void show(BuildContext context, Map<String, dynamic>? config) {
    final s = (config?['settings'] as Map<String, dynamic>?) ?? {};
    final phone = (s['supportPhone']?.toString().isNotEmpty == true) ? s['supportPhone'].toString() : '01711-889900';
    final wa = (s['supportWhatsapp']?.toString().isNotEmpty == true) ? s['supportWhatsapp'].toString() : phone;
    final office = s['officeAddress']?.toString() ?? 'মাইজদী কোর্ট রোড, নোয়াখালী সদর';
    final email = s['supportEmail']?.toString() ?? 'support@landtrust.com.bd';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.support_agent, color: Color(0xFF0B4F32)),
          SizedBox(width: 8),
          Text('হেল্পলাইন ও সহায়তা', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ভূমি সেতু নোয়াখালী অফিস:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
            const SizedBox(height: 8),
            Text('📞 হটলাইন: $phone', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            Text('📍 অফিস: $office', style: const TextStyle(fontSize: 12.5)),
            const SizedBox(height: 4),
            Text('✉️ ইমেইল: $email', style: const TextStyle(fontSize: 12.5)),
          ],
        ),
        actions: [
          OutlinedButton.icon(
            icon: const Icon(Icons.chat, size: 16, color: Color(0xFF25D366)),
            label: const Text('WhatsApp চ্যাট', style: TextStyle(fontSize: 12.5, color: Color(0xFF075E54))),
            onPressed: () {
              Navigator.pop(ctx);
              WhatsAppHelper.openChat(phone: wa, message: 'আসসালামু আলাইকুম। আমি ভূমি সেতু সম্পর্কিত বিষয়ে যোগাযোগ করতে চাই।');
            },
          ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ঠিক আছে')),
        ],
      ),
    );
  }
}
