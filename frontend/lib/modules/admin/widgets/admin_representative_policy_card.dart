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
    _fieldShareCtrl = TextEditingController(text: '${s['dealClosureFieldSharePercent'] ?? 70}');
    _upzShareCtrl = TextEditingController(text: '${s['dealClosureUpazilaSharePercent'] ?? 20}');
    _distShareCtrl = TextEditingController(text: '${s['dealClosureDistrictSharePercent'] ?? 10}');
  }

  @override
  void dispose() {
    for (final c in [_distFeeCtrl, _upzFeeCtrl, _offPouFeeCtrl, _offUniFeeCtrl, _fieldShareCtrl, _upzShareCtrl, _distShareCtrl]) {
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
            const Text('প্রতিনিধি নেটওয়ার্ক ফি ও ৩-স্তরের কমিশন বণ্টন পলিসি', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0A2E1F))),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _w(TextField(controller: _distFeeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'জেলা প্রধান এজেন্ট ফি (৳)', isDense: true))),
                _w(TextField(controller: _upzFeeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'উপজেলা এজেন্ট ফি (৳)', isDense: true))),
                _w(TextField(controller: _offPouFeeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'পৌরসভা অফিসার ফি (৳)', isDense: true))),
                _w(TextField(controller: _offUniFeeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'ইউনিয়ন অফিসার ফি (৳)', isDense: true))),
                _w(TextField(controller: _fieldShareCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'মাঠ অফিসার শেয়ার (%)', isDense: true))),
                _w(TextField(controller: _upzShareCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'উপজেলা এজেন্ট ওভাররাইড (%)', isDense: true))),
                _w(TextField(controller: _distShareCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'জেলা এজেন্ট ওভাররাইড (%)', isDense: true))),
              ],
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.save, size: 16),
              label: const Text('প্রতিনিধি পলিসি সংরক্ষণ'),
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
