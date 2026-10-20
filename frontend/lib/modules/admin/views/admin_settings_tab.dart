import 'package:flutter/material.dart';
import '../view_models/admin_view_model.dart';
import '../widgets/admin_settings_dialogs.dart';

class AdminSettingsTab extends StatefulWidget {
  final AdminViewModel viewModel;
  final bool isMobile;

  const AdminSettingsTab({super.key, required this.viewModel, required this.isMobile});

  @override
  State<AdminSettingsTab> createState() => _AdminSettingsTabState();
}

class _AdminSettingsTabState extends State<AdminSettingsTab> {
  late final TextEditingController _buyerFeeCtrl, _sellerFeeCtrl, _officerFeeCtrl;
  late final TextEditingController _phoneCtrl, _emailCtrl, _addrCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final s = (widget.viewModel.dashboard['settings'] as Map<String, dynamic>?) ?? {};
    _buyerFeeCtrl = TextEditingController(text: '${s['buyerRegistrationFee'] ?? 500}');
    _sellerFeeCtrl = TextEditingController(text: '${s['sellerRegistrationFee'] ?? 500}');
    _officerFeeCtrl = TextEditingController(text: '${s['officerRegistrationFee'] ?? 300}');
    _phoneCtrl = TextEditingController(text: s['supportPhone'] ?? '01800-000000');
    _emailCtrl = TextEditingController(text: s['supportEmail'] ?? 'support@landtrust.com.bd');
    _addrCtrl = TextEditingController(text: s['officeAddress'] ?? 'মাইজদী কোর্ট, নোয়াখালী');
  }

  @override
  void dispose() {
    for (final c in [_buyerFeeCtrl, _sellerFeeCtrl, _officerFeeCtrl, _phoneCtrl, _emailCtrl, _addrCtrl]) {
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
        'supportEmail': _emailCtrl.text.trim(),
        'officeAddress': _addrCtrl.text.trim(),
      });
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
        _buildPaymentMethodsCard(widget.viewModel.paymentMethods),
        const SizedBox(height: 14),
        _buildLocationsCard(widget.viewModel.locations),
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

  Widget _buildPaymentMethodsCard(List<dynamic> pms) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(widget.isMobile ? 12 : 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                Text('নিবন্ধন ফি গ্রহণের পেমেন্ট মাধ্যম (${pms.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
                  onPressed: () => AdminSettingsDialogs.showAddPaymentMethodDialog(context, isMobile: widget.isMobile, onSubmit: widget.viewModel.createPaymentMethod),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('নতুন মেথড যোগ'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...pms.map((pm) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.account_balance_wallet, color: Color(0xFF0B4F32)),
                  title: Text('${pm['providerName']} (${pm['accountType']})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text('নম্বর: ${pm['accountNumber']}', style: const TextStyle(fontSize: 11)),
                  trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), onPressed: () => widget.viewModel.deletePaymentMethod(pm['id'] as int)),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationsCard(List<dynamic> locs) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(widget.isMobile ? 12 : 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                Text('কভারেজ জেলা ও উপজেলাসমূহ (${locs.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
                  onPressed: () => AdminSettingsDialogs.showAddLocationDialog(context, isMobile: widget.isMobile, onSubmit: widget.viewModel.createLocation),
                  icon: const Icon(Icons.add_location_alt, size: 16),
                  label: const Text('নতুন এলাকা যোগ'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: locs.map((l) => Chip(
                    label: Text('${l['districtNameBn']} - ${l['upazilaNameBn']}', style: const TextStyle(fontSize: 11.5)),
                    onDeleted: () => widget.viewModel.deleteLocation(l['id'] as int),
                    deleteIconColor: Colors.red,
                  )).toList(),
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
