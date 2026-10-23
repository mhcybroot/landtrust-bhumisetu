import 'package:flutter/material.dart';
import '../../../../core/animations/bouncing_pressable.dart';
import '../../../../core/animations/pulse_beacon_indicator.dart';
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
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.support_agent, color: Color(0xFF0B4F32), size: 24),
              Positioned(
                right: -2,
                top: -2,
                child: PulseBeaconIndicator(color: Color(0xFF10B981), size: 8),
              ),
            ],
          ),
          SizedBox(width: 10),
          Text('হেল্পলাইন ও সহায়তা', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('bdHousing সাপোর্ট ও হেল্পলাইন:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
            const SizedBox(height: 8),
            Text('📞 হটলাইন: $phone', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            Text('📍 সেন্ট্রাল অফিস: $office', style: const TextStyle(fontSize: 12.5)),
            const SizedBox(height: 4),
            Text('✉️ ইমেইল: $email', style: const TextStyle(fontSize: 12.5)),
          ],
        ),
        actions: [
          BouncingPressable(
            onTap: () {
              Navigator.pop(ctx);
              WhatsAppHelper.openChat(phone: wa, message: 'আসসালামু আলাইকুম। আমি bdHousing সম্পর্কিত বিষয়ে যোগাযোগ করতে চাই।');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF25D366)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat, size: 16, color: Color(0xFF25D366)),
                  SizedBox(width: 6),
                  Text('WhatsApp চ্যাট', style: TextStyle(fontSize: 12.5, color: Color(0xFF075E54), fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ঠিক আছে')),
        ],
      ),
    );
  }
}
