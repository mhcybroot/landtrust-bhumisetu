import 'package:flutter/material.dart';
import '../view_models/admin_view_model.dart';

class AdminListingFeesCard extends StatefulWidget {
  final AdminViewModel viewModel;
  final bool isMobile;
  final VoidCallback? onSaved;

  const AdminListingFeesCard({
    super.key,
    required this.viewModel,
    required this.isMobile,
    this.onSaved,
  });

  @override
  State<AdminListingFeesCard> createState() => _AdminListingFeesCardState();
}

class _AdminListingFeesCardState extends State<AdminListingFeesCard> {
  late final TextEditingController _feeAgriCtrl;
  late final TextEditingController _feeResCtrl;
  late final TextEditingController _feeFlatCtrl;
  late final TextEditingController _feeCommCtrl;
  late final TextEditingController _feeFeaturedCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final s = (widget.viewModel.dashboard['settings'] as Map<String, dynamic>?) ?? {};
    _feeAgriCtrl = TextEditingController(text: '${s['listingFeeAgri'] ?? 500}');
    _feeResCtrl = TextEditingController(text: '${s['listingFeeResidential'] ?? 1000}');
    _feeFlatCtrl = TextEditingController(text: '${s['listingFeeFlat'] ?? 1500}');
    _feeCommCtrl = TextEditingController(text: '${s['listingFeeCommercial'] ?? 2000}');
    _feeFeaturedCtrl = TextEditingController(text: '${s['listingFeeFeaturedExtra'] ?? 1000}');
  }

  @override
  void dispose() {
    for (final c in [_feeAgriCtrl, _feeResCtrl, _feeFlatCtrl, _feeCommCtrl, _feeFeaturedCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _saveFees() async {
    setState(() => _saving = true);
    try {
      await widget.viewModel.updateSettings({
        'listingFeeAgri': double.tryParse(_feeAgriCtrl.text.trim()) ?? 500,
        'listingFeeResidential': double.tryParse(_feeResCtrl.text.trim()) ?? 1000,
        'listingFeeFlat': double.tryParse(_feeFlatCtrl.text.trim()) ?? 1500,
        'listingFeeCommercial': double.tryParse(_feeCommCtrl.text.trim()) ?? 2000,
        'listingFeeFeaturedExtra': double.tryParse(_feeFeaturedCtrl.text.trim()) ?? 1000,
      });
      widget.onSaved?.call();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('মাল্টি-লেভেল বিজ্ঞাপন ফি সফলভাবে সংরক্ষিত হয়েছে!')),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(widget.isMobile ? 12 : 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.price_change, color: Color(0xFF0B4F32), size: 22),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'মাল্টি-লেভেল লিস্টিং ও বিজ্ঞাপন ফি কনফিগারেশন',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0A2E1F)),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)),
                  child: const Text('ডায়নামিক রেট', style: TextStyle(fontSize: 11, color: Color(0xFF0B4F32), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'জমি, ফ্ল্যাট ও বাণিজ্যিক বিজ্ঞাপনের ক্যাটাগরিভিত্তিক রেজিস্ট্রেশন ফি নির্ধারণ করুন। এটি পরিবর্তন করলে নতুন লিস্টিংয়ে প্রযোজ্য হবে।',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _w(TextField(controller: _feeAgriCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '🌾 কৃষি জমি ফি (৳)', isDense: true))),
                _w(TextField(controller: _feeResCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '🏡 আবাসিক জমি / প্লট ফি (৳)', isDense: true))),
                _w(TextField(controller: _feeFlatCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '🏢 ফ্ল্যাট / অ্যাপার্টমেন্ট ফি (৳)', isDense: true))),
                _w(TextField(controller: _feeCommCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '🏪 বাণিজ্যিক স্পেস / দোকান ফি (৳)', isDense: true))),
                _w(TextField(controller: _feeFeaturedCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '⭐ ফিচার্ড / ভিআইপি অতিরিক্ত ফি (৳)', isDense: true))),
              ],
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
              onPressed: _saving ? null : _saveFees,
              icon: _saving ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save, size: 16),
              label: const Text('লিস্টিং ফি আপডেট করুন'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _w(Widget child) {
    return LayoutBuilder(builder: (ctx, constraints) {
      final width = widget.isMobile ? constraints.maxWidth : (constraints.maxWidth - 20) / 3;
      return SizedBox(width: width, child: child);
    });
  }
}
