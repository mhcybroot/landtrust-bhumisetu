import 'package:flutter/material.dart';

class MobileFilterBottomSheet extends StatefulWidget {
  final List<String> upazilas;
  final String initialUpazila;
  final String initialLandType;
  final String initialVerification;
  final TextEditingController maxBudgetCtrl;
  final TextEditingController minAreaCtrl;
  final TextEditingController maxAreaCtrl;
  final void Function(String upazila, String landType, String verification) onApply;
  final VoidCallback onReset;

  const MobileFilterBottomSheet({
    super.key,
    required this.upazilas,
    required this.initialUpazila,
    required this.initialLandType,
    required this.initialVerification,
    required this.maxBudgetCtrl,
    required this.minAreaCtrl,
    required this.maxAreaCtrl,
    required this.onApply,
    required this.onReset,
  });

  static void show(
    BuildContext context, {
    required List<String> upazilas,
    required String initialUpazila,
    required String initialLandType,
    required String initialVerification,
    required TextEditingController maxBudgetCtrl,
    required TextEditingController minAreaCtrl,
    required TextEditingController maxAreaCtrl,
    required void Function(String upazila, String landType, String verification) onApply,
    required VoidCallback onReset,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => MobileFilterBottomSheet(
        upazilas: upazilas,
        initialUpazila: initialUpazila,
        initialLandType: initialLandType,
        initialVerification: initialVerification,
        maxBudgetCtrl: maxBudgetCtrl,
        minAreaCtrl: minAreaCtrl,
        maxAreaCtrl: maxAreaCtrl,
        onApply: onApply,
        onReset: onReset,
      ),
    );
  }

  @override
  State<MobileFilterBottomSheet> createState() => _MobileFilterBottomSheetState();
}

class _MobileFilterBottomSheetState extends State<MobileFilterBottomSheet> {
  late String _upazila;
  late String _landType;
  late String _verification;

  @override
  void initState() {
    super.initState();
    _upazila = widget.initialUpazila;
    _landType = widget.initialLandType;
    _verification = widget.initialVerification;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 18,
        right: 18,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 18,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ফিল্টার অপশন', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  widget.onReset();
                  Navigator.pop(context);
                },
                child: const Text('রিসেট', style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _upazila.isEmpty ? null : _upazila,
            decoration: const InputDecoration(labelText: 'উপজেলা নির্বাচন করুন', border: OutlineInputBorder()),
            items: [
              const DropdownMenuItem(value: '', child: Text('সব উপজেলা (নোয়াখালী)')),
              ...widget.upazilas.map((u) => DropdownMenuItem(value: u, child: Text(u))),
            ],
            onChanged: (v) => setState(() => _upazila = v ?? ''),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: widget.maxBudgetCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'সর্বোচ্চ বাজেট (টাকা)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.minAreaCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'ন্যূনতম শতক', border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: widget.maxAreaCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'সর্বোচ্চ শতক', border: OutlineInputBorder()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B4F32),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                widget.onApply(_upazila, _landType, _verification);
                Navigator.pop(context);
              },
              child: const Text('ফিল্টার প্রয়োগ করুন', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}
