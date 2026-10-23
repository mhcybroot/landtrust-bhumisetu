import 'package:flutter/material.dart';
import '../../../core/animations/bouncing_pressable.dart';
import '../../../core/constants/app_constants.dart';
import '../view_models/admin_view_model.dart';
import '../widgets/admin_listing_fees_card.dart';
import '../widgets/admin_representative_policy_card.dart';
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
  late final TextEditingController _buyerFeeCtrl, _sellerFeePourashavaCtrl, _sellerFeeUnionCtrl, _officerFeeCtrl;
  late final TextEditingController _phoneCtrl, _whatsappCtrl, _emailCtrl, _addrCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final s = (widget.viewModel.dashboard['settings'] as Map<String, dynamic>?) ?? {};
    _buyerFeeCtrl = TextEditingController(text: '${s['buyerRegistrationFee'] ?? 1000}');
    _sellerFeePourashavaCtrl = TextEditingController(text: '${s['sellerRegistrationFeePourashava'] ?? 2000}');
    _sellerFeeUnionCtrl = TextEditingController(text: '${s['sellerRegistrationFeeUnion'] ?? 1000}');
    _officerFeeCtrl = TextEditingController(text: '${s['officerRegistrationFee'] ?? 1000}');
    _phoneCtrl = TextEditingController(text: s['supportPhone'] ?? AppConstants.defaultSupportPhone);
    _whatsappCtrl = TextEditingController(text: s['supportWhatsapp'] ?? s['supportPhone'] ?? AppConstants.defaultSupportWhatsapp);
    _emailCtrl = TextEditingController(text: s['supportEmail'] ?? AppConstants.defaultSupportEmail);
    _addrCtrl = TextEditingController(text: s['officeAddress'] ?? AppConstants.defaultOfficeAddress);
    widget.viewModel.addListener(_syncSettings);
  }

  void _syncField(TextEditingController ctrl, dynamic val, String baseline) {
    if (val == null) return;
    if (ctrl.text.isEmpty || ctrl.text == baseline) ctrl.text = '$val';
  }

  void _syncSettings() {
    if (_saving || !mounted) return;
    final s = (widget.viewModel.dashboard['settings'] as Map<String, dynamic>?) ?? {};
    if (s.isEmpty) return;
    _syncField(_buyerFeeCtrl, s['buyerRegistrationFee'], '1000');
    _syncField(_sellerFeePourashavaCtrl, s['sellerRegistrationFeePourashava'], '2000');
    _syncField(_sellerFeeUnionCtrl, s['sellerRegistrationFeeUnion'], '1000');
    _syncField(_officerFeeCtrl, s['officerRegistrationFee'], '1000');
    _syncField(_phoneCtrl, s['supportPhone'], AppConstants.defaultSupportPhone);
    _syncField(_whatsappCtrl, s['supportWhatsapp'], AppConstants.defaultSupportWhatsapp);
    _syncField(_emailCtrl, s['supportEmail'], AppConstants.defaultSupportEmail);
    _syncField(_addrCtrl, s['officeAddress'], AppConstants.defaultOfficeAddress);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_syncSettings);
    for (final c in [_buyerFeeCtrl, _sellerFeePourashavaCtrl, _sellerFeeUnionCtrl, _officerFeeCtrl, _phoneCtrl, _whatsappCtrl, _emailCtrl, _addrCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _saveSettings() async {
    setState(() => _saving = true);
    try {
      await widget.viewModel.updateSettings({
        'buyerRegistrationFee': double.tryParse(_buyerFeeCtrl.text.trim()) ?? 1000,
        'sellerRegistrationFeePourashava': double.tryParse(_sellerFeePourashavaCtrl.text.trim()) ?? 2000,
        'sellerRegistrationFeeUnion': double.tryParse(_sellerFeeUnionCtrl.text.trim()) ?? 1000,
        'officerRegistrationFee': double.tryParse(_officerFeeCtrl.text.trim()) ?? 1000,
        'supportPhone': _phoneCtrl.text.trim(),
        'supportWhatsapp': _whatsappCtrl.text.trim(),
        'supportEmail': _emailCtrl.text.trim(),
        'officeAddress': _addrCtrl.text.trim(),
      });
      widget.onSettingsSaved?.call();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('পলিসি ও সাপোর্ট সেটিংস সফলভাবে সংরক্ষিত হয়েছে!')),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGeneralSettingsCard(),
        const SizedBox(height: 16),
        AdminListingFeesCard(viewModel: widget.viewModel, isMobile: widget.isMobile, onSaved: widget.onSettingsSaved),
        const SizedBox(height: 16),
        AdminRepresentativePolicyCard(viewModel: widget.viewModel, isMobile: widget.isMobile, onSaved: widget.onSettingsSaved),
        const SizedBox(height: 16),
        AdminPaymentMethodsCard(viewModel: widget.viewModel, isMobile: widget.isMobile, onSaved: widget.onSettingsSaved),
        const SizedBox(height: 16),
        AdminLocationsCard(viewModel: widget.viewModel, isMobile: widget.isMobile, onSaved: widget.onSettingsSaved),
      ],
    );
  }

  Widget _buildGeneralSettingsCard() {
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
              spacing: 10, runSpacing: 10,
              children: [
                _w(TextField(controller: _buyerFeeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'ক্রেতা নিবন্ধন ফি (৳)', isDense: true))),
                _w(TextField(controller: _sellerFeePourashavaCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'শহর/পৌরসভা বিক্রেতা ফি (৳)', isDense: true))),
                _w(TextField(controller: _sellerFeeUnionCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'ইউনিয়ন বিক্রেতা ফি (৳)', isDense: true))),
                _w(TextField(controller: _officerFeeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'মার্কেটিং অফিসার ফি (৳)', isDense: true))),
                _w(TextField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'হেল্পলাইন মোবাইল', isDense: true))),
                _w(TextField(controller: _whatsappCtrl, decoration: const InputDecoration(labelText: 'সাপোর্ট WhatsApp নম্বর', isDense: true))),
                _w(TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'সাপোর্ট ইমেইল', isDense: true))),
                _w(TextField(controller: _addrCtrl, decoration: const InputDecoration(labelText: 'প্রধান অফিসের ঠিকানা', isDense: true))),
              ],
            ),
            const SizedBox(height: 14),
            BouncingPressable(
              onTap: _saving ? null : _saveSettings,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
                onPressed: _saving ? null : _saveSettings,
                icon: const Icon(Icons.save, size: 16),
                label: const Text('সংরক্ষণ করুন'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _w(Widget child) => LayoutBuilder(builder: (ctx, constraints) => SizedBox(width: widget.isMobile ? constraints.maxWidth : (constraints.maxWidth - 20) / 3, child: child));
}
