import 'package:flutter/material.dart';
import 'package:landtrust_app/core/animations/bouncing_pressable.dart';
import 'package:landtrust_app/core/animations/legal_verification_animations.dart';
import 'package:landtrust_app/core/network/api_client.dart';

class NrbServiceDialog extends StatefulWidget {
  final VoidCallback? onSuccess;
  final bool isMobile;

  const NrbServiceDialog({super.key, this.onSuccess, required this.isMobile});

  static void show(BuildContext context, {VoidCallback? onSuccess, required bool isMobile}) {
    showDialog(context: context, builder: (ctx) => NrbServiceDialog(onSuccess: onSuccess, isMobile: isMobile));
  }

  @override
  State<NrbServiceDialog> createState() => _NrbServiceDialogState();
}

class _NrbServiceDialogState extends State<NrbServiceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _countryCtrl = TextEditingController(text: 'সৌদি আরব');
  final _phoneCtrl = TextEditingController();
  final _passportCtrl = TextEditingController();
  final _districtCtrl = TextEditingController(text: 'নোয়াখালী');
  final _upazilaCtrl = TextEditingController(text: 'নোয়াখালী সদর');
  final _khatianCtrl = TextEditingController();
  final _dagCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _serviceType = 'INSTITUTIONAL_REPRESENTATION';
  bool _isLoading = false;

  @override
  void dispose() {
    for (final c in [_countryCtrl, _phoneCtrl, _passportCtrl, _districtCtrl, _upazilaCtrl, _khatianCtrl, _dagCtrl, _areaCtrl, _priceCtrl, _notesCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final payload = {
        'countryOfResidence': _countryCtrl.text.trim(),
        'overseasPhone': _phoneCtrl.text.trim(),
        'whatsappNumber': _phoneCtrl.text.trim(),
        'passportNumber': _passportCtrl.text.trim(),
        'district': _districtCtrl.text.trim(),
        'upazila': _upazilaCtrl.text.trim(),
        'khatianNo': _khatianCtrl.text.trim(),
        'dagNo': _dagCtrl.text.trim(),
        'landAreaDecimal': double.tryParse(_areaCtrl.text.trim()) ?? 0,
        'askingPriceBdt': double.tryParse(_priceCtrl.text.trim()) ?? 0,
        'serviceType': _serviceType,
        'notes': _notesCtrl.text.trim(),
      };
      final res = await ApiClient.post('/member/nrb/request', body: payload);
      if (res.statusCode == 200 && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('প্রবাসী প্রতিনিধিত্ব ও PoA আবেদন জমা হয়েছে!')));
        widget.onSuccess?.call();
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('আবেদন জমায় ত্রুটি হয়েছে')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: widget.isMobile ? 360 : 500),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                const SizedBox(height: 12),
                _buildNoticeBox(),
                const SizedBox(height: 12),
                _buildTypeRow(),
                const SizedBox(height: 12),
                _field(_countryCtrl, 'বসবাসরত দেশ (Country)', 'সৌদি আরব, ইউএই, ওমান', true),
                const SizedBox(height: 8),
                _field(_phoneCtrl, 'বিদেশের মোবাইল/WhatsApp', '+966xxxxxxxxx', true),
                const SizedBox(height: 8),
                _field(_passportCtrl, 'পাসপোর্ট / এনআইডি নম্বর', 'যাচাইয়ের জন্য আবশ্যক', false),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: _field(_districtCtrl, 'জমির জেলা', 'জেলা', true)),
                  const SizedBox(width: 8),
                  Expanded(child: _field(_upazilaCtrl, 'উপজেলা/থানা', 'উপজেলা', true)),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: _field(_khatianCtrl, 'খতিয়ান নং', 'খতিয়ান', false)),
                  const SizedBox(width: 8),
                  Expanded(child: _field(_dagCtrl, 'দাগ নং', 'দাগ', false)),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: _field(_areaCtrl, 'পরিমাণ (শতক)', '৫', false, isNum: true)),
                  const SizedBox(width: 8),
                  Expanded(child: _field(_priceCtrl, 'কাঙ্ক্ষিত মূল্য (৳)', '২৫০০০০০', false, isNum: true)),
                ]),
                const SizedBox(height: 8),
                _field(_notesCtrl, 'বিশেষ নির্দেশনা বা শর্তাবলী', 'মালিকের কোনো বিশেষ শর্ত থাকলে...', false, maxLines: 2),
                const SizedBox(height: 16),
                _buildButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(children: [
      Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.flight_takeoff, color: Color(0xFF0B4F32), size: 22)),
      const SizedBox(width: 8),
      const Expanded(child: Text('প্রবাসী জমি বিক্রয় ও PoA সেবা', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0B4F32)))),
      const TrustSealStamp(size: 26),
      const SizedBox(width: 4),
      BouncingPressable(onTap: () => Navigator.pop(context), child: const Icon(Icons.close)),
    ]);
  }

  Widget _buildNoticeBox() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber.shade400)),
      child: const Text('🛡️ সুরক্ষা শর্ত: জমির সকল মূল্য সরাসরি প্রবাসীর ব্যাংক একাউন্টে জমা হবে। কোনো প্রতিনিধি নগদ টাকা গ্রহণ করবে না। PoA দূতাবাসের মাধ্যমে সত্যায়িত হতে হবে।', style: TextStyle(fontSize: 10.5, color: Color(0xFF5D4037), height: 1.3)),
    );
  }

  Widget _buildTypeRow() {
    return Row(children: [
      Expanded(child: BouncingPressable(onTap: () => setState(() => _serviceType = 'INSTITUTIONAL_REPRESENTATION'), child: ChoiceChip(label: const Text('১. প্রাতিষ্ঠানিক প্রতিনিধি', style: TextStyle(fontSize: 11)), selected: _serviceType == 'INSTITUTIONAL_REPRESENTATION', onSelected: (_) => setState(() => _serviceType = 'INSTITUTIONAL_REPRESENTATION')))),
      const SizedBox(width: 6),
      Expanded(child: BouncingPressable(onTap: () => setState(() => _serviceType = 'POWER_OF_ATTORNEY'), child: ChoiceChip(label: const Text('২. পাওয়ার অব অ্যাটর্নি', style: TextStyle(fontSize: 11)), selected: _serviceType == 'POWER_OF_ATTORNEY', onSelected: (_) => setState(() => _serviceType = 'POWER_OF_ATTORNEY')))),
    ]);
  }

  Widget _field(TextEditingController c, String l, String h, bool req, {bool isNum = false, int maxLines = 1}) {
    return TextFormField(
      controller: c,
      maxLines: maxLines,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(labelText: l, hintText: h, border: const OutlineInputBorder(), isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
      validator: req ? (v) => (v == null || v.trim().isEmpty) ? '$l দিন' : null : null,
    );
  }

  Widget _buildButtons() {
    return Wrap(
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      children: [
        BouncingPressable(onTap: () => Navigator.pop(context), child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('বাতিল'))),
        BouncingPressable(
          onTap: _isLoading ? null : _submit,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
            onPressed: _isLoading ? null : _submit,
            child: _isLoading ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('আবেদন জমা দিন'),
          ),
        ),
      ],
    );
  }
}
