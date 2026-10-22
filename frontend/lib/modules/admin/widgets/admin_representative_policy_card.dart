import 'package:flutter/material.dart';
import '../view_models/admin_view_model.dart';

class AdminRepresentativePolicyCard extends StatefulWidget {
  final AdminViewModel viewModel;
  final bool isMobile;
  final VoidCallback? onSaved;

  const AdminRepresentativePolicyCard({
    super.key,
    required this.viewModel,
    required this.isMobile,
    this.onSaved,
  });

  @override
  State<AdminRepresentativePolicyCard> createState() => _AdminRepresentativePolicyCardState();
}

class _AdminRepresentativePolicyCardState extends State<AdminRepresentativePolicyCard> {
  late final TextEditingController _distFeeCtrl, _upzFeeCtrl, _offPouFeeCtrl, _offUniFeeCtrl;
  late final TextEditingController _buyerCommCtrl, _sellerPouCommCtrl, _sellerUniCommCtrl, _listingCommCtrl;
  late final TextEditingController _fieldShareCtrl, _upzShareCtrl, _distShareCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final s = (widget.viewModel.dashboard['settings'] as Map<String, dynamic>?) ?? {};
    _distFeeCtrl = TextEditingController(text: '${s['districtAgentRegistrationFee'] ?? 10000}');
    _upzFeeCtrl = TextEditingController(text: '${s['upazilaAgentRegistrationFee'] ?? 5000}');
    _offPouFeeCtrl = TextEditingController(text: '${s['officerRegistrationFeePourashava'] ?? 2000}');
    _offUniFeeCtrl = TextEditingController(text: '${s['officerRegistrationFeeUnion'] ?? 1000}');
    _buyerCommCtrl = TextEditingController(text: '${s['buyerRegCommission'] ?? 100}');
    _sellerPouCommCtrl = TextEditingController(text: '${s['sellerRegCommissionPourashava'] ?? 200}');
    _sellerUniCommCtrl = TextEditingController(text: '${s['sellerRegCommissionUnion'] ?? 100}');
    _listingCommCtrl = TextEditingController(text: '${s['listingRegCommission'] ?? 100}');
    _fieldShareCtrl = TextEditingController(text: '${s['dealClosureFieldSharePercent'] ?? 70}');
    _upzShareCtrl = TextEditingController(text: '${s['dealClosureUpazilaSharePercent'] ?? 20}');
    _distShareCtrl = TextEditingController(text: '${s['dealClosureDistrictSharePercent'] ?? 10}');
    widget.viewModel.addListener(_syncSettings);
  }

  void _syncSettings() {
    if (_saving || !mounted) return;
    final s = (widget.viewModel.dashboard['settings'] as Map<String, dynamic>?) ?? {};
    if (s.isEmpty) return;
    if (s['districtAgentRegistrationFee'] != null) _distFeeCtrl.text = '${s['districtAgentRegistrationFee']}';
    if (s['upazilaAgentRegistrationFee'] != null) _upzFeeCtrl.text = '${s['upazilaAgentRegistrationFee']}';
    if (s['officerRegistrationFeePourashava'] != null) _offPouFeeCtrl.text = '${s['officerRegistrationFeePourashava']}';
    if (s['officerRegistrationFeeUnion'] != null) _offUniFeeCtrl.text = '${s['officerRegistrationFeeUnion']}';
    if (s['buyerRegCommission'] != null) _buyerCommCtrl.text = '${s['buyerRegCommission']}';
    if (s['sellerRegCommissionPourashava'] != null) _sellerPouCommCtrl.text = '${s['sellerRegCommissionPourashava']}';
    if (s['sellerRegCommissionUnion'] != null) _sellerUniCommCtrl.text = '${s['sellerRegCommissionUnion']}';
    if (s['listingRegCommission'] != null) _listingCommCtrl.text = '${s['listingRegCommission']}';
    if (s['dealClosureFieldSharePercent'] != null) _fieldShareCtrl.text = '${s['dealClosureFieldSharePercent']}';
    if (s['dealClosureUpazilaSharePercent'] != null) _upzShareCtrl.text = '${s['dealClosureUpazilaSharePercent']}';
    if (s['dealClosureDistrictSharePercent'] != null) _distShareCtrl.text = '${s['dealClosureDistrictSharePercent']}';
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_syncSettings);
    for (final c in [_distFeeCtrl, _upzFeeCtrl, _offPouFeeCtrl, _offUniFeeCtrl, _buyerCommCtrl, _sellerPouCommCtrl, _sellerUniCommCtrl, _listingCommCtrl, _fieldShareCtrl, _upzShareCtrl, _distShareCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await widget.viewModel.updateSettings({
        'districtAgentRegistrationFee': double.tryParse(_distFeeCtrl.text.trim()) ?? 10000,
        'upazilaAgentRegistrationFee': double.tryParse(_upzFeeCtrl.text.trim()) ?? 5000,
        'officerRegistrationFeePourashava': double.tryParse(_offPouFeeCtrl.text.trim()) ?? 2000,
        'officerRegistrationFeeUnion': double.tryParse(_offUniFeeCtrl.text.trim()) ?? 1000,
        'buyerRegCommission': double.tryParse(_buyerCommCtrl.text.trim()) ?? 100,
        'sellerRegCommissionPourashava': double.tryParse(_sellerPouCommCtrl.text.trim()) ?? 200,
        'sellerRegCommissionUnion': double.tryParse(_sellerUniCommCtrl.text.trim()) ?? 100,
        'listingRegCommission': double.tryParse(_listingCommCtrl.text.trim()) ?? 100,
        'dealClosureFieldSharePercent': double.tryParse(_fieldShareCtrl.text.trim()) ?? 70,
        'dealClosureUpazilaSharePercent': double.tryParse(_upzShareCtrl.text.trim()) ?? 20,
        'dealClosureDistrictSharePercent': double.tryParse(_distShareCtrl.text.trim()) ?? 10,
      });
      widget.onSaved?.call();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('প্রতিনিধি ও কমিশন পলিসি সংরক্ষিত হয়েছে!')));
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
            const Text('প্রতিনিধি ফি, প্রতি রেজিস্ট্রেশন কমিশন ও ডিল লভ্যাংশ পলিসি', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0A2E1F))),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _w(TextField(controller: _distFeeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'জেলা প্রধান এজেন্ট ফি (৳)', isDense: true))),
                _w(TextField(controller: _upzFeeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'উপজেলা এজেন্ট ফি (৳)', isDense: true))),
                _w(TextField(controller: _offPouFeeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'পৌরসভা অফিসার ফি (৳)', isDense: true))),
                _w(TextField(controller: _offUniFeeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'ইউনিয়ন অফিসার ফি (৳)', isDense: true))),
                _w(TextField(controller: _buyerCommCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'ক্রেতা নিবন্ধন কমিশন (৳)', isDense: true))),
                _w(TextField(controller: _sellerPouCommCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'পৌর বিক্রেতা কমিশন (৳)', isDense: true))),
                _w(TextField(controller: _sellerUniCommCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'ইউনিয়ন বিক্রেতা কমিশন (৳)', isDense: true))),
                _w(TextField(controller: _listingCommCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'প্রতি লিস্টিং কমিশন (৳)', isDense: true))),
                _w(TextField(controller: _fieldShareCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'মাঠ অফিসার ডিল শেয়ার (%)', isDense: true))),
                _w(TextField(controller: _upzShareCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'উপজেলা এজেন্ট ওভাররাইড (%)', isDense: true))),
                _w(TextField(controller: _distShareCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'জেলা এজেন্ট ওভাররাইড (%)', isDense: true))),
              ],
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.save, size: 16),
              label: const Text('প্রতিনিধি ও কমিশন পলিসি সংরক্ষণ'),
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
