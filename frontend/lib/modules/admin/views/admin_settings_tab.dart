import 'package:flutter/material.dart';
import '../view_models/admin_view_model.dart';
import '../widgets/admin_settings_extra_cards.dart';

class AdminSettingsTab extends StatefulWidget {
  final AdminViewModel viewModel;
  final bool isMobile;
  final VoidCallback? onSettingsSaved;

  const AdminSettingsTab({
    super.key,
    required this.viewModel,
    required this.isMobile,
    this.onSettingsSaved,
  });

  @override
  State<AdminSettingsTab> createState() => _AdminSettingsTabState();
}

class _AdminSettingsTabState extends State<AdminSettingsTab> {
  late final TextEditingController _buyerFeeCtrl, _sellerFeeCtrl, _officerFeeCtrl;
  late final TextEditingController _phoneCtrl, _whatsappCtrl, _emailCtrl, _addrCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final s = (widget.viewModel.dashboard['settings'] as Map<String, dynamic>?) ?? {};
    _buyerFeeCtrl = TextEditingController(text: '${s['buyerRegistrationFee'] ?? 500}');
    _sellerFeeCtrl = TextEditingController(text: '${s['sellerRegistrationFee'] ?? 500}');
    _officerFeeCtrl = TextEditingController(text: '${s['officerRegistrationFee'] ?? 300}');
    _phoneCtrl = TextEditingController(text: s['supportPhone'] ?? '01711-889900');
    _whatsappCtrl = TextEditingController(text: s['supportWhatsapp'] ?? s['supportPhone'] ?? '01711-889900');
    _emailCtrl = TextEditingController(text: s['supportEmail'] ?? 'support@landtrust.com.bd');
    _addrCtrl = TextEditingController(text: s['officeAddress'] ?? 'মাইজদী কোর্ট, নোয়াখালী');
    widget.viewModel.addListener(_syncSettings);
  }

  void _syncSettings() {
    if (_saving || !mounted) return;
    final s = (widget.viewModel.dashboard['settings'] as Map<String, dynamic>?) ?? {};
    if (s.isEmpty) return;
    if (s['supportPhone'] != null && _phoneCtrl.text != s['supportPhone']) {
      _phoneCtrl.text = s['supportPhone'].toString();
    }
    if (s['supportWhatsapp'] != null && _whatsappCtrl.text != s['supportWhatsapp']) {
      _whatsappCtrl.text = s['supportWhatsapp'].toString();
    }
    if (s['supportEmail'] != null && _emailCtrl.text != s['supportEmail']) {
      _emailCtrl.text = s['supportEmail'].toString();
    }
    if (s['officeAddress'] != null && _addrCtrl.text != s['officeAddress']) {
      _addrCtrl.text = s['officeAddress'].toString();
    }
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_syncSettings);
    for (final c in [_buyerFeeCtrl, _sellerFeeCtrl, _officerFeeCtrl, _phoneCtrl, _whatsappCtrl, _emailCtrl, _addrCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _saveSettings() async {
    setState(() => _saving = true);
    try {
      await widget.viewModel.updateSettings({
        'buyerRegistrationFee': double.tryParse(_buyerFeeCtrl.text.trim()) ?? 500,
        'sellerRegistrationFee': double.tryParse(_sellerFeeCtrl.text.trim()) ?? 500,
        'officerRegistrationFee': double.tryParse(_officerFeeCtrl.text.trim()) ?? 300,
        'supportPhone': _phoneCtrl.text.trim(),
        'supportWhatsapp': _whatsappCtrl.text.trim(),
        'supportEmail': _emailCtrl.text.trim(),
        'officeAddress': _addrCtrl.text.trim(),
      });
      widget.onSettingsSaved?.call();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('সেটিংস সফলভাবে সংরক্ষিত হয়েছে!')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFeesCard(),
        const SizedBox(height: 14),
        AdminPaymentMethodsCard(viewModel: widget.viewModel, isMobile: widget.isMobile, onSaved: widget.onSettingsSaved),
        const SizedBox(height: 14),
        AdminLocationsCard(viewModel: widget.viewModel, isMobile: widget.isMobile, onSaved: widget.onSettingsSaved),
      ],
    );
  }

  Widget _buildFeesCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(widget.isMobile ? 12 : 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('নিবন্ধন ফি ও প্ল্যাটফর্ম পলিসি কনফিগারেশন', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0A2E1F))),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _w(TextField(controller: _buyerFeeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'ক্রেতা নিবন্ধন ফি (৳)', isDense: true))),
                _w(TextField(controller: _sellerFeeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'বিক্রেতা নিবন্ধন ফি (৳)', isDense: true))),
                _w(TextField(controller: _officerFeeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'মার্কেটিং অফিসার ফি (৳)', isDense: true))),
                _w(TextField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'হেল্পলাইন মোবাইল', isDense: true))),
                _w(TextField(controller: _whatsappCtrl, decoration: const InputDecoration(labelText: 'সাপোর্ট WhatsApp নম্বর', isDense: true))),
                _w(TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'সাপোর্ট ইমেইল', isDense: true))),
                _w(TextField(controller: _addrCtrl, decoration: const InputDecoration(labelText: 'প্রধান অফিসের ঠিকানা', isDense: true))),
              ],
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
              onPressed: _saving ? null : _saveSettings,
              icon: const Icon(Icons.save, size: 16),
              label: const Text('সংরক্ষণ করুন'),
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
