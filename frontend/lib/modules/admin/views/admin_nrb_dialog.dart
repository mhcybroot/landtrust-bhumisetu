import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:landtrust_app/core/animations/bouncing_pressable.dart';
import 'package:landtrust_app/core/network/api_client.dart';

class AdminNrbDialog extends StatefulWidget {
  final bool isMobile;

  const AdminNrbDialog({super.key, required this.isMobile});

  static void show(BuildContext context, {required bool isMobile}) {
    showDialog(context: context, builder: (ctx) => AdminNrbDialog(isMobile: isMobile));
  }

  @override
  State<AdminNrbDialog> createState() => _AdminNrbDialogState();
}

class _AdminNrbDialogState extends State<AdminNrbDialog> {
  List<dynamic> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiClient.get('/admin/nrb/requests');
      if (res.statusCode == 200) {
        setState(() {
          _requests = jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(dynamic req, String newStatus, String notes) async {
    final id = req['id'];
    await ApiClient.put('/admin/nrb/requests/$id/status', body: {'poaStatus': newStatus, 'adminNotes': notes});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('স্ট্যাটাস আপডেট হয়েছে: $newStatus')));
      _loadRequests();
    }
  }

  void _openManageSheet(dynamic r) {
    final noteCtrl = TextEditingController(text: r['adminNotes']?.toString() ?? '');
    String status = r['poaStatus']?.toString() ?? 'SUBMITTED';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('প্রবাসী আবেদন ব্যবস্থাপনা #${r['id']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('আবেদনকারী: ${r['applicantName']} (${r['countryOfResidence']})', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('ফোন/WhatsApp: ${r['overseasPhone']}'),
              Text('প্রপার্টি: ${r['upazila']}, ${r['district']} (দাগ: ${r['dagNo'] ?? '-'})'),
              const SizedBox(height: 12),
              const Text('বর্তমান স্ট্যাটাস পরিবর্তন করুন:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: status,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'SUBMITTED', child: Text('১. আবেদন জমা হয়েছে (SUBMITTED)')),
                  DropdownMenuItem(value: 'UNDER_LEGAL_REVIEW', child: Text('২. আইনি স্ক্রুটিনি চলছে (UNDER_LEGAL_REVIEW)')),
                  DropdownMenuItem(value: 'EMBASSY_DRAFT_READY', child: Text('৩. দূতাবাস PoA ড্রাফট প্রস্তুত (EMBASSY_DRAFT_READY)')),
                  DropdownMenuItem(value: 'ATTESTED', child: Text('৪. দূতাবাসে সত্যায়িত (ATTESTED)')),
                  DropdownMenuItem(value: 'REGISTERED', child: Text('৫. অনুমোদিত ও কার্যকর (REGISTERED)')),
                  DropdownMenuItem(value: 'REJECTED', child: Text('৬. বাতিল (REJECTED)')),
                ],
                onChanged: (v) => setDlgState(() => status = v!),
              ),
              const SizedBox(height: 8),
              TextField(controller: noteCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'অ্যাডমিন মন্তব্য / নির্দেশ')),
            ],
          ),
          actions: [
            BouncingPressable(onTap: () => Navigator.pop(ctx), child: TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল'))),
            BouncingPressable(
              onTap: () { Navigator.pop(ctx); _updateStatus(r, status, noteCtrl.text.trim()); },
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
                onPressed: () { Navigator.pop(ctx); _updateStatus(r, status, noteCtrl.text.trim()); },
                child: const Text('সংরক্ষণ করুন'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: widget.isMobile ? 380 : 700, maxHeight: 620),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(children: [
                    Icon(Icons.flight_takeoff, color: Color(0xFF0B4F32)),
                    SizedBox(width: 8),
                    Text('প্রবাসী প্রতিনিধিত্ব ও PoA আবেদনসমূহ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ]),
                  BouncingPressable(onTap: () => Navigator.pop(context), child: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _requests.isEmpty
                        ? const Center(child: Text('কোনো প্রবাসী আবেদন জমা নেই।'))
                        : ListView.separated(
                            itemCount: _requests.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 8),
                            itemBuilder: (ctx, i) {
                              final r = _requests[i];
                              return Card(
                                child: ListTile(
                                  title: Text('${r['applicantName']} — ${r['countryOfResidence']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                                  subtitle: Text('প্রপার্টি: ${r['upazila']}, ${r['district']} • সেবা: ${r['serviceType']}\nস্ট্যাটাস: ${r['poaStatus']}', style: const TextStyle(fontSize: 11)),
                                  trailing: BouncingPressable(
                                    onTap: () => _openManageSheet(r),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
                                      onPressed: () => _openManageSheet(r),
                                      child: const Text('ব্যবস্থাপনা', style: TextStyle(fontSize: 11)),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
