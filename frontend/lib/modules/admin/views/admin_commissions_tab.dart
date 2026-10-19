import 'package:flutter/material.dart';
import 'package:landtrust_app/core/widgets/csv_export_dialog.dart';
import '../view_models/admin_view_model.dart';
import '../widgets/award_commission_dialog.dart';

class AdminCommissionsTab extends StatelessWidget {
  final AdminViewModel viewModel;
  final bool isMobile;

  const AdminCommissionsTab({
    super.key,
    required this.viewModel,
    required this.isMobile,
  });

  void _exportCsv(BuildContext context) {
    final buffer = StringBuffer();
    buffer.writeln('ID,OfficerName,ReferralCode,ReferredMember,Role,CommissionType,BaseDealBDT,PercentRate,CommissionBDT,Status,PaymentRef');
    for (final c in viewModel.commissions) {
      buffer.writeln(
        '${c['id']},"${c['officerName']}","${c['referralCode']}","${c['referredUserName']}","${c['referredUserRole']}","${c['commissionType']}",${c['baseDealAmountBdt']},${c['percentageRate']},${c['commissionAmountBdt']},"${c['status']}","${c['paymentReference'] ?? ''}"',
      );
    }
    CsvExportDialog.show(context, title: 'মার্কেটিং অফিসার কমিশন রিপোর্ট (CSV)', content: buffer.toString());
  }

  void _markPaid(BuildContext context, Map<String, dynamic> c) {
    final refCtrl = TextEditingController(text: 'BKASH-REF-${DateTime.now().millisecondsSinceEpoch % 100000}');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('কমিশন পরিশোধ নিশ্চিতকরণ (${c['officerName']})', style: const TextStyle(fontSize: 16)),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('কমিশন পরিমাণ: ৳${c['commissionAmountBdt']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B4F32))),
              const SizedBox(height: 10),
              TextField(controller: refCtrl, decoration: const InputDecoration(labelText: 'পেমেন্ট রেফারেন্স / TrxID *', isDense: true)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
            onPressed: () async {
              if (refCtrl.text.trim().isEmpty) return;
              await viewModel.markCommissionPaid(c['id'] as int, refCtrl.text.trim());
              if (context.mounted) Navigator.pop(ctx);
            },
            child: const Text('পরিশোধ সম্পন্ন'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final commissions = viewModel.commissions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () => _exportCsv(context),
              icon: const Icon(Icons.table_view, size: 18),
              label: const Text('📊 CSV রিপোর্ট'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
              onPressed: () => AwardCommissionDialog.show(context, users: viewModel.users, isMobile: isMobile, onSubmit: viewModel.awardCommission),
              icon: const Icon(Icons.military_tech_outlined, size: 18),
              label: const Text('ডিল কমিশন বরাদ্দ'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (commissions.isEmpty)
          const Card(child: Padding(padding: EdgeInsets.all(32), child: Center(child: Text('কোনো কমিশন হিসেব নেই।'))))
        else
          ...commissions.map((c) {
            final isPaid = c['status'] == 'PAID';
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                child: Row(
                  children: [
                    Icon(isPaid ? Icons.check_circle : Icons.pending, color: isPaid ? Colors.green : Colors.orange, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${c['officerName']} (${c['referralCode']})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('রেফারেল: ${c['referredUserName']} • ধরন: ${c['commissionType']}', style: const TextStyle(fontSize: 12, color: Colors.black87)),
                          if (c['paymentReference'] != null) Text('রেফারেন্স: ${c['paymentReference']}', style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('৳${c['commissionAmountBdt']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0B4F32))),
                        const SizedBox(height: 4),
                        if (!isPaid)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                            onPressed: () => _markPaid(context, c as Map<String, dynamic>),
                            child: const Text('পরিশোধ করুন', style: TextStyle(fontSize: 11)),
                          )
                        else
                          const Text('পরিশোধিত', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}
