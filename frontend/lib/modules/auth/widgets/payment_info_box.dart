import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
            'নিবন্ধন ফি: ৳$fee (নিচের নম্বরে Send Money করুন)',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
                    InkWell(
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
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.copy, size: 15, color: Color(0xFF0B4F32)),
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
