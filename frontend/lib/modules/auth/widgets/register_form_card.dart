import 'package:flutter/material.dart';
import '../../../../core/animations/transitions/finance_payment_transitions.dart';
import 'payment_info_box.dart';
import 'role_selector_widget.dart';

class RegisterFormCard extends StatefulWidget {
  final Map<String, dynamic> config;
  final bool isMobile;
  final bool isLoading;
  final Future<void> Function(Map<String, dynamic> payload) onSubmit;

  const RegisterFormCard({
    super.key,
    required this.config,
    required this.isMobile,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  State<RegisterFormCard> createState() => _RegisterFormCardState();
}

class _RegisterFormCardState extends State<RegisterFormCard> {
  String _selectedRole = 'BUYER';
  final _fullNameCtrl = TextEditingController(), _phoneCtrl = TextEditingController(), _passCtrl = TextEditingController();
  final _addressCtrl = TextEditingController(), _senderPhoneCtrl = TextEditingController(), _trxIdCtrl = TextEditingController();
  late final TextEditingController _referralCodeCtrl;
  String _district = 'নোয়াখালী', _upazila = 'নোয়াখালী সদর', _selectedPaymentMethod = 'বিকাশ (bKash)';
  bool _obscurePass = true;

  @override
  void initState() {
    super.initState();
    final ref = Uri.base.queryParameters['ref'] ?? '';
    _referralCodeCtrl = TextEditingController(text: ref.trim());
  }

  @override
  void dispose() {
    for (final c in [_fullNameCtrl, _phoneCtrl, _passCtrl, _addressCtrl, _referralCodeCtrl, _senderPhoneCtrl, _trxIdCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = (widget.config['settings'] as Map<String, dynamic>?) ?? {};
    final paymentMethods = (widget.config['paymentMethods'] as List<dynamic>?) ?? [];
    final locations = (widget.config['locations'] as List<dynamic>?) ?? [];

    final districts = locations.isNotEmpty
        ? locations.map((l) => l['districtNameBn'].toString()).toSet().toList()
        : ['নোয়াখালী'];
    if (!districts.contains(_district)) _district = districts.first;

    final upazilas = locations
        .where((l) => l['districtNameBn'] == _district)
        .map((l) => l['upazilaNameBn'].toString())
        .toSet()
        .toList();
    final upazilaList = upazilas.isNotEmpty
        ? upazilas
        : ['নোয়াখালী সদর', 'বেগমগঞ্জ', 'চৌমুহনী পৌরসভা'];
    if (!upazilaList.contains(_upazila)) _upazila = upazilaList.first;

    final paymentOptions = paymentMethods.isNotEmpty
        ? paymentMethods.map((pm) => pm['providerName'].toString()).toSet().toList()
        : ['বিকাশ (bKash)', 'নগদ (Nagad)', 'ইসলামী ব্যাংক পিএলসি'];
    if (!paymentOptions.contains(_selectedPaymentMethod)) _selectedPaymentMethod = paymentOptions.first;

    final isPourashava = locations.any((l) => l['districtNameBn'] == _district && l['upazilaNameBn'] == _upazila && l['areaType'] == 'POURASHAVA') || _upazila.contains('পৌরসভা') || _upazila.contains('সিটি কর্পোরেশন');

    final roleFee = switch (_selectedRole) {
      'DISTRICT_AGENT' => settings['districtAgentRegistrationFee'] ?? 10000,
      'UPAZILA_AGENT' => settings['upazilaAgentRegistrationFee'] ?? 5000,
      'MARKETING_OFFICER' => isPourashava ? (settings['officerRegistrationFeePourashava'] ?? 2000) : (settings['officerRegistrationFeeUnion'] ?? 1000),
      'SELLER' => isPourashava ? (settings['sellerRegistrationFeePourashava'] ?? 2000) : (settings['sellerRegistrationFeeUnion'] ?? 1000),
      _ => settings['buyerRegistrationFee'] ?? 1000,
    };

    final isOrdinaryUser = _selectedRole == 'BUYER' || _selectedRole == 'SELLER';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(widget.isMobile ? 14 : 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'সদস্য ও প্রতিনিধি নিবন্ধন ফর্ম',
              style: TextStyle(fontSize: widget.isMobile ? 17 : 20, fontWeight: FontWeight.bold, color: const Color(0xFF0B4F32)),
            ),
            const SizedBox(height: 12),
            RoleSelectorWidget(
              selectedRole: _selectedRole,
              isMobile: widget.isMobile,
              settings: settings,
              onRoleSelected: (r) => setState(() => _selectedRole = r),
            ),
            const SizedBox(height: 14),
            _buildInputs(districts, upazilaList, locations),
            if (isOrdinaryUser) ...[
              const SizedBox(height: 10),
              TextField(controller: _referralCodeCtrl, decoration: const InputDecoration(labelText: 'রেফারেল কোড (ঐচ্ছিক, যেমন: LT-OFF-1001)', prefixIcon: Icon(Icons.card_giftcard, size: 18), isDense: true)),
            ],
            const SizedBox(height: 14),
            PaymentInfoBox(fee: roleFee, paymentMethods: paymentMethods),
            const SizedBox(height: 12),
            _buildPaymentInputs(paymentOptions),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: widget.isLoading ? null : _handleRegister,
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: Text('নিবন্ধন সম্পন্ন করুন (ফি: ৳$roleFee)', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 8),
            const Center(child: Text('নিবন্ধন করার মাধ্যমে আপনি আমাদের গোপনীয়তা ও শর্তাবলীতে সম্মত হচ্ছেন।', style: TextStyle(fontSize: 10.5, color: Colors.grey), textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputs(List<String> districts, List<String> upazilas, List<dynamic> locations) {
    return LayoutBuilder(builder: (ctx, constraints) {
      final half = widget.isMobile ? constraints.maxWidth : (constraints.maxWidth - 10) / 2;
      return Wrap(spacing: 10, runSpacing: 10, children: [
        SizedBox(width: half, child: TextField(controller: _fullNameCtrl, decoration: const InputDecoration(labelText: 'পূর্ণ নাম *', isDense: true))),
        SizedBox(width: half, child: TextField(controller: _phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'মোবাইল নম্বর (01XXXXXXXXX) *', isDense: true))),
        SizedBox(width: half, child: TextField(controller: _passCtrl, obscureText: _obscurePass, decoration: InputDecoration(labelText: 'পাসওয়ার্ড (কমপক্ষে ৬ অক্ষর) *', isDense: true, suffixIcon: IconButton(icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility, size: 18), onPressed: () => setState(() => _obscurePass = !_obscurePass))))),
        SizedBox(width: half, child: DropdownButtonFormField<String>(key: ValueKey('reg_dist_$_district'), initialValue: _district, isExpanded: true, decoration: const InputDecoration(labelText: 'জেলা', isDense: true), items: districts.map((d) => DropdownMenuItem(value: d, child: Text(d, overflow: TextOverflow.ellipsis))).toList(), onChanged: (v) {
          if (v == null) return;
          final newUpz = locations.where((l) => l['districtNameBn'] == v).map((l) => l['upazilaNameBn'].toString()).toSet().toList();
          setState(() { _district = v; _upazila = newUpz.isNotEmpty ? newUpz.first : ''; });
        })),
        SizedBox(width: half, child: DropdownButtonFormField<String>(key: ValueKey('reg_upz_${_district}_$_upazila'), initialValue: _upazila, isExpanded: true, decoration: const InputDecoration(labelText: 'উপজেলা / পৌরসভা', isDense: true), items: upazilas.map((u) => DropdownMenuItem(value: u, child: Text(u, overflow: TextOverflow.ellipsis))).toList(), onChanged: (v) => setState(() => _upazila = v!))),
        SizedBox(width: half, child: TextField(controller: _addressCtrl, decoration: const InputDecoration(labelText: 'বর্তমান ঠিকানা / ইউনিয়ন / ওয়ার্ড', isDense: true))),
      ]);
    });
  }

  Widget _buildPaymentInputs(List<String> options) {
    return LayoutBuilder(builder: (ctx, constraints) {
      final half = widget.isMobile ? constraints.maxWidth : (constraints.maxWidth - 10) / 2;
      return Wrap(spacing: 10, runSpacing: 10, children: [
        SizedBox(width: half, child: DropdownButtonFormField<String>(key: ValueKey('reg_pm_$_selectedPaymentMethod'), initialValue: _selectedPaymentMethod, isExpanded: true, decoration: const InputDecoration(labelText: 'পেমেন্টের মাধ্যম', isDense: true), items: options.map((p) => DropdownMenuItem(value: p, child: Text(p, overflow: TextOverflow.ellipsis))).toList(), onChanged: (v) => setState(() => _selectedPaymentMethod = v!))),
        SizedBox(width: half, child: TextField(controller: _senderPhoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'প্রেরক মোবাইল নম্বর *', isDense: true))),
        SizedBox(width: constraints.maxWidth, child: OtpDigitBoxPulseTransition(isFocused: _trxIdCtrl.text.isNotEmpty, child: TextField(controller: _trxIdCtrl, decoration: const InputDecoration(labelText: 'ট্রানজ্যাকশন আইডি (TrxID) *', isDense: true)))),
      ]);
    });
  }

  void _handleRegister() {
    final name = _fullNameCtrl.text.trim();
    final cleanPhone = _phoneCtrl.text.trim().replaceAll(RegExp(r'[\s\-]'), '');
    final pass = _passCtrl.text;
    final trx = _trxIdCtrl.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('অনুগ্রহ করে পূর্ণ নাম লিখুন।')));
      return;
    }
    if (!RegExp(r'^01[3-9]\d{8}$').hasMatch(cleanPhone)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('সঠিক ১১ ডিজিটের মোবাইল নম্বর দিন (যেমন: 017xxxxxxxx)')));
      return;
    }
    if (pass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('পাসওয়ার্ড ন্যূনতম ৬ অক্ষরের হতে হবে।')));
      return;
    }
    if (trx.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('অনুগ্রহ করে পেমেন্টের TrxID প্রদান করুন।')));
      return;
    }
    final isOrdinary = _selectedRole == 'BUYER' || _selectedRole == 'SELLER';
    widget.onSubmit({
      'fullName': name,
      'phoneNumber': cleanPhone,
      'password': pass,
      'role': _selectedRole,
      'district': _district,
      'upazila': _upazila,
      'address': _addressCtrl.text.trim(),
      'referralCode': isOrdinary ? _referralCodeCtrl.text.trim() : '',
      'paymentMethod': _selectedPaymentMethod,
      'senderPhone': _senderPhoneCtrl.text.trim().isEmpty ? cleanPhone : _senderPhoneCtrl.text.trim(),
      'transactionId': trx,
    });
  }
}
