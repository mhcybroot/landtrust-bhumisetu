import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:landtrust_app/core/animations/bouncing_pressable.dart';
import 'package:landtrust_app/core/animations/transitions/finance_payment_transitions.dart';
import 'package:landtrust_app/core/network/api_client.dart';
import 'nrb_request_card.dart';
import 'nrb_service_dialog.dart';

class MyNrbRequestsDialog extends StatefulWidget {
  final bool isMobile;

  const MyNrbRequestsDialog({super.key, required this.isMobile});

  static void show(BuildContext context, {required bool isMobile}) {
    showDialog(context: context, builder: (ctx) => MyNrbRequestsDialog(isMobile: isMobile));
  }

  @override
  State<MyNrbRequestsDialog> createState() => _MyNrbRequestsDialogState();
}

class _MyNrbRequestsDialogState extends State<MyNrbRequestsDialog> {
  List<dynamic> _requests = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final res = await ApiClient.get('/member/nrb/my-requests');
      if (res.statusCode == 200) {
        setState(() {
          _requests = jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'লোড ব্যর্থ (${res.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'ত্রুটি: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: widget.isMobile ? 380 : 600, maxHeight: 600),
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
                    Text('আমার প্রবাসী সেবা ও PoA আবেদন', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ]),
                  BouncingPressable(onTap: () => Navigator.pop(context), child: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 6),
              const Text('দূতাবাস সত্যায়ন, লিগ্যাল স্ক্রুটিনি ও সাব-রেজিস্ট্রি অগ্রগতি:', style: TextStyle(fontSize: 11.5, color: Colors.black54)),
              const SizedBox(height: 6),
              const EscrowStatusProgressStepTransition(currentStep: 2, totalSteps: 4),
              const SizedBox(height: 12),
              Expanded(child: _buildBody()),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BouncingPressable(
                    onTap: () => NrbServiceDialog.show(context, onSuccess: _loadRequests, isMobile: widget.isMobile),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
                      onPressed: () => NrbServiceDialog.show(context, onSuccess: _loadRequests, isMobile: widget.isMobile),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('নতুন আবেদন', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  BouncingPressable(onTap: () => Navigator.pop(context), child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('বন্ধ করুন'))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(_error!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 8),
          BouncingPressable(onTap: _loadRequests, child: ElevatedButton(onPressed: _loadRequests, child: const Text('পুনরায় চেষ্টা'))),
        ]),
      );
    }
    if (_requests.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
          const SizedBox(height: 8),
          const Text('আপনার কোনো প্রবাসী প্রতিনিধিত্ব বা PoA আবেদন নেই।', style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 12),
          BouncingPressable(
            onTap: () => NrbServiceDialog.show(context, onSuccess: _loadRequests, isMobile: widget.isMobile),
            child: OutlinedButton(
              onPressed: () => NrbServiceDialog.show(context, onSuccess: _loadRequests, isMobile: widget.isMobile),
              child: const Text('প্রবাস থেকে প্রতিনিধি সেবার আবেদন করুন'),
            ),
          ),
        ]),
      );
    }
    return ListView.builder(
      itemCount: _requests.length,
      itemBuilder: (ctx, i) => NrbRequestCard(request: _requests[i] as Map<String, dynamic>, isMobile: widget.isMobile),
    );
  }
}
