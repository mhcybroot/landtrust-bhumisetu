import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/animations/bouncing_pressable.dart';

class PaymentInfoBox extends StatelessWidget {
  final dynamic fee;
  final List<dynamic> paymentMethods;

  const PaymentInfoBox({
    super.key,
    required this.fee,
    required this.paymentMethods,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.shade600),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'সার্ভিস ফি: ৳${(fee as num?)?.toInt() ?? fee} (ফিল্ড পরিদর্শন, নথি যাচাই ও লিস্টিং ফি)',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0B4F32)),
          ),
          const SizedBox(height: 2),
          const Text(
            'নিচের যেকোনো অনুমোদিত নম্বরে Send Money করে TrxID প্রদান করুন:',
            style: TextStyle(fontSize: 11, color: Colors.black54),
          ),
          const SizedBox(height: 6),
          ...paymentMethods.map((pm) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '👉 ${pm['providerName']}: ${pm['accountNumber']} (${pm['accountType']})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Color(0xFF0B4F32),
                        ),
                      ),
                    ),
                    BouncingPressable(
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(text: pm['accountNumber'].toString()),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${pm['accountNumber']} কপি হয়েছে!'),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B4F32).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.copy, size: 13, color: Color(0xFF0B4F32)),
                            SizedBox(width: 3),
                            Text('কপি', style: TextStyle(fontSize: 10, color: Color(0xFF0B4F32), fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
