import 'package:flutter/material.dart';

class ListingPaymentSection extends StatelessWidget {
  final double feeAmount;
  final bool isFeatured;
  final ValueChanged<bool> onFeaturedChanged;
  final List<dynamic> paymentMethods;
  final String selectedMethod;
  final ValueChanged<String> onMethodChanged;
  final TextEditingController senderPhoneCtrl;
  final TextEditingController trxIdCtrl;
  final bool isMobile;

  const ListingPaymentSection({
    super.key,
    required this.feeAmount,
    required this.isFeatured,
    required this.onFeaturedChanged,
    required this.paymentMethods,
    required this.selectedMethod,
    required this.onMethodChanged,
    required this.senderPhoneCtrl,
    required this.trxIdCtrl,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? currentMethod;
    for (final m in paymentMethods) {
      if (m is Map<String, dynamic> && m['providerName'] == selectedMethod) {
        currentMethod = m;
        break;
      }
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAF8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDCE7DF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.payment, size: 18, color: Color(0xFF0B4F32)),
              const SizedBox(width: 6),
              const Expanded(
                child: Text('বিজ্ঞাপন রেজিস্ট্রেশন ফি ও পেমেন্ট', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0A2E1F))),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(6)),
                child: Text('ফি: ৳${feeAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0B4F32))),
              ),
            ],
          ),
          const SizedBox(height: 6),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: const Text('⭐ ফিচার্ড লিস্টিং (মার্কেটপ্লেসের শীর্ষে হাইলাইট)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
            subtitle: const Text('অতিরিক্ত প্রমোশন চার্জ প্রযোজ্য', style: TextStyle(fontSize: 11, color: Colors.black54)),
            value: isFeatured,
            onChanged: (val) => onFeaturedChanged(val ?? false),
          ),
          const SizedBox(height: 6),
          if (paymentMethods.isNotEmpty)
            DropdownButtonFormField<String>(
              value: paymentMethods.any((m) => m['providerName'] == selectedMethod)
                  ? selectedMethod
                  : paymentMethods.first['providerName'].toString(),
              decoration: const InputDecoration(labelText: 'পেমেন্ট মাধ্যম *', isDense: true),
              items: paymentMethods
                  .map((m) => DropdownMenuItem(
                        value: m['providerName'].toString(),
                        child: Text('${m['providerName']} (${m['accountNumber'] ?? ''})', style: const TextStyle(fontSize: 12)),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val != null) onMethodChanged(val);
              },
            ),
          if (currentMethod != null && currentMethod['instructions'] != null) ...[
            const SizedBox(height: 4),
            Text(currentMethod['instructions'].toString(), style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: senderPhoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'প্রেরক মোবাইল নম্বর *', isDense: true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: trxIdCtrl,
                  decoration: const InputDecoration(labelText: 'ট্রানজেকশন আইডি (TrxID) *', isDense: true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
