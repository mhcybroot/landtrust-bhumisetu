import 'package:flutter/material.dart';
import 'package:landtrust_app/core/widgets/csv_export_dialog.dart';
import 'package:landtrust_app/core/widgets/status_badge.dart';
import 'package:landtrust_app/modules/member_portal/widgets/agreement_certificate_dialog.dart';
import '../view_models/admin_view_model.dart';
import '../widgets/admin_finance_dialogs.dart';

class AdminFinanceProposalsTab extends StatefulWidget {
  final AdminViewModel viewModel;
  final bool isMobile;

  const AdminFinanceProposalsTab({
    super.key,
    required this.viewModel,
    required this.isMobile,
  });

  @override
  State<AdminFinanceProposalsTab> createState() => _AdminFinanceProposalsTabState();
}

class _AdminFinanceProposalsTabState extends State<AdminFinanceProposalsTab> {
  bool _showProposals = false;

  void _exportTransactionsCsv() {
    final buffer = StringBuffer();
    buffer.writeln('ID,FundBucket,TxnType,AmountBDT,UserName,PaymentMethod,TransactionID,Status,Description,CreatedAt');
    for (final t in widget.viewModel.transactions) {
      buffer.writeln(
        '${t['id']},"${t['fundBucket']}","${t['txnType']}",${t['amountBdt']},"${t['userName'] ?? ''}","${t['paymentMethod'] ?? ''}","${t['transactionId'] ?? ''}","${t['status'] ?? ''}","${t['description'] ?? ''}","${t['createdAt'] ?? ''}"',
      );
    }
    CsvExportDialog.show(context, title: '৩-খাত আর্থিক লেজার রিপোর্ট (CSV)', content: buffer.toString());
  }

  @override
  Widget build(BuildContext context) {
    final txns = widget.viewModel.transactions;
    final proposals = widget.viewModel.proposals;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: !_showProposals ? const Color(0xFF0B4F32) : Colors.grey.shade200,
                  foregroundColor: !_showProposals ? Colors.white : Colors.black87,
                ),
                onPressed: () => setState(() => _showProposals = false),
                child: Text('৩-খাত আর্থিক লেজার (${txns.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _showProposals ? const Color(0xFF0B4F32) : Colors.grey.shade200,
                  foregroundColor: _showProposals ? Colors.white : Colors.black87,
                ),
                onPressed: () => setState(() => _showProposals = true),
                child: Text('বিশেষ চুক্তি প্রস্তাবনা (${proposals.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (!_showProposals) _buildTransactionsSection(txns) else _buildProposalsSection(proposals),
      ],
    );
  }

  Widget _buildTransactionsSection(List<dynamic> txns) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: _exportTransactionsCsv,
              icon: const Icon(Icons.table_view, size: 18),
              label: const Text('📊 লেজার CSV কপি'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
              onPressed: () => AdminFinanceDialogs.showAddExpenseDialog(context, isMobile: widget.isMobile, onSubmit: widget.viewModel.addExpense),
              icon: const Icon(Icons.remove_circle_outline, size: 18),
              label: const Text('তহবিল ব্যয় এন্ট্রি'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (txns.isEmpty)
          const Card(child: Padding(padding: EdgeInsets.all(32), child: Center(child: Text('কোনো আর্থিক লেনদেন রেকর্ড নেই।'))))
        else
          ...txns.map((t) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: EdgeInsets.all(widget.isMobile ? 12 : 14),
                  child: Row(
                    children: [
                      Icon(t['txnType'] == 'INCOME' ? Icons.arrow_downward : Icons.arrow_upward, color: t['txnType'] == 'INCOME' ? Colors.green : Colors.red, size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t['description'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text('খাত: ${t['fundBucket']} • মাধ্যম: ${t['paymentMethod'] ?? '-'}', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('৳${t['amountBdt']}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: t['txnType'] == 'INCOME' ? const Color(0xFF0B4F32) : Colors.red.shade700)),
                          Text(t['status'] ?? '', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
              )),
      ],
    );
  }

  Widget _buildProposalsSection(List<dynamic> proposals) {
    if (proposals.isEmpty) {
      return const Card(child: Padding(padding: EdgeInsets.all(32), child: Center(child: Text('কোনো বিশেষ চুক্তি প্রস্তাব নেই।'))));
    }
    return Column(
      children: proposals.map((p) {
        final isAgreed = p['status'] == 'MUTUALLY_AGREED' || p['status'] == 'COMPLETED';
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: EdgeInsets.all(widget.isMobile ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(p['proposalTitle'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5))),
                    StatusBadge(status: p['status']),
                  ],
                ),
                const SizedBox(height: 4),
                Text('গ্রাহক: ${p['customerName']} (${p['customerRole']})'),
                const SizedBox(height: 2),
                Text(p['scopeDescription'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.black87)),
                const SizedBox(height: 4),
                Text('প্রস্তাবিত ফি: ৳${p['customerProposedFeeBdt']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B4F32))),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (!isAgreed) ...[
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
                        onPressed: () => widget.viewModel.respondProposal(p['id'] as int, 'AGREE', agreedFee: (p['customerProposedFeeBdt'] as num).toDouble()),
                        child: const Text('সম্মতি দিন (Agree)', style: TextStyle(fontSize: 11)),
                      ),
                      OutlinedButton(
                        onPressed: () => AdminFinanceDialogs.showCounterOfferDialog(context, proposal: p as Map<String, dynamic>, isMobile: widget.isMobile, onSubmit: (fee, note) => widget.viewModel.respondProposal(p['id'] as int, 'COUNTER', notes: note, agreedFee: fee)),
                        child: const Text('পাল্টা প্রস্তাব', style: TextStyle(fontSize: 11)),
                      ),
                    ],
                    OutlinedButton.icon(
                      onPressed: () => AgreementCertificateDialog.show(context, proposal: p as Map<String, dynamic>, isMobile: widget.isMobile),
                      icon: const Icon(Icons.verified_outlined, size: 15),
                      label: const Text('চুক্তিপত্র সনদ', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
