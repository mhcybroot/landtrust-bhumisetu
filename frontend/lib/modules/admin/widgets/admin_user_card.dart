import 'package:flutter/material.dart';
import 'package:landtrust_app/core/utils/communication_utils.dart';
import 'package:landtrust_app/core/widgets/status_badge.dart';
import '../view_models/admin_view_model.dart';
import 'admin_communication_dialogs.dart';
import 'admin_user_dialogs.dart';

class AdminUserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final AdminViewModel viewModel;
  final bool isMobile;

  const AdminUserCard({
    super.key,
    required this.user,
    required this.viewModel,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final status = user['accountStatus'] as String? ?? 'PAYMENT_SUBMITTED';
    final isPending = status == 'PAYMENT_SUBMITTED';
    final phone = user['phoneNumber']?.toString() ?? '';
    final name = user['fullName']?.toString() ?? '';

    final roleBn = switch (user['role']?.toString()) {
      'DISTRICT_AGENT' => 'জেলা প্রধান এজেন্ট',
      'UPAZILA_AGENT' => 'উপজেলা এজেন্ট',
      'MARKETING_OFFICER' => 'মার্কেটিং অফিসার',
      'SELLER' => 'জমির বিক্রেতা',
      'BUYER' => 'জমির ক্রেতা',
      _ => user['role']?.toString() ?? '',
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text('${user['fullName']} ($roleBn)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                StatusBadge(status: status),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(child: Text('মোবাইল: $phone • এলাকা: ${user['upazila']}, ${user['district']}')),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.chat, size: 18, color: Color(0xFF25D366)),
                  tooltip: 'WhatsApp',
                  onPressed: () {
                    if (isPending) {
                      CommunicationUtils.openPaymentVerificationChat(
                        phone: phone,
                        userName: name,
                        trxId: user['transactionId']?.toString() ?? '',
                        method: user['paymentMethod']?.toString(),
                      );
                    } else {
                      CommunicationUtils.launchWhatsApp(
                        phone: phone,
                        message: 'আসসালামু আলাইকুম $name, LandApp টিম থেকে যোগাযোগ করছি।',
                      );
                    }
                  },
                ),
                const SizedBox(width: 8),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.phone, size: 18, color: Colors.blue),
                  tooltip: 'কল দিন',
                  onPressed: () => CommunicationUtils.makePhoneCall(phone),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'পেমেন্ট: ${user['paymentMethod']} (প্রেরক: ${user['senderPhone'] ?? '-'}) • TrxID: ${user['transactionId'] ?? '-'}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B4F32), fontSize: 12),
            ),
            if (user['myReferralCode'] != null) Text('অফিসার কোড: ${user['myReferralCode']}', style: const TextStyle(fontSize: 11, color: Colors.blue)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (isPending)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
                    onPressed: () => AdminUserDialogs.showVerifyPaymentDialog(
                      context,
                      user: user,
                      isMobile: isMobile,
                      onSubmit: (app, note) => viewModel.verifyUserPayment(user['id'] as int, app, note),
                    ),
                    icon: const Icon(Icons.check_circle, size: 15),
                    label: const Text('পেমেন্ট যাচাই করুন', style: TextStyle(fontSize: 11)),
                  ),
                OutlinedButton.icon(
                  onPressed: () => AdminUserDialogs.showResetPasswordDialog(
                    context,
                    user: user,
                    isMobile: isMobile,
                    onSubmit: (pass) => viewModel.resetUserPassword(user['id'] as int, pass),
                  ),
                  icon: const Icon(Icons.lock_reset, size: 15),
                  label: const Text('পাসওয়ার্ড রিসেট', style: TextStyle(fontSize: 11)),
                ),
                OutlinedButton.icon(
                  onPressed: () => AdminCommunicationDialogs.showSendNotificationDialog(
                    context,
                    user: user,
                    isMobile: isMobile,
                    onSubmit: (title, msg) => viewModel.sendNotificationToUser(user['id'] as int, title, msg),
                  ),
                  icon: const Icon(Icons.notifications_active_outlined, size: 15),
                  label: const Text('নোটিশ পাঠান', style: TextStyle(fontSize: 11)),
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red.shade800),
                  onPressed: () => AdminUserDialogs.showRefundFeeDialog(
                    context,
                    user: user,
                    isMobile: isMobile,
                    onSubmit: (reason, trx) => viewModel.refundUserFee(user['id'] as int, reason, trx),
                  ),
                  icon: const Icon(Icons.money_off, size: 15),
                  label: const Text('ফি রিফান্ড', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
