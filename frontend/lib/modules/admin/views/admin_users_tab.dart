import 'package:flutter/material.dart';
import 'package:landtrust_app/core/widgets/status_badge.dart';
import '../view_models/admin_view_model.dart';
import '../widgets/admin_user_dialogs.dart';

class AdminUsersTab extends StatefulWidget {
  final AdminViewModel viewModel;
  final bool isMobile;

  const AdminUsersTab({
    super.key,
    required this.viewModel,
    required this.isMobile,
  });

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  String _filterRole = '';
  String _filterStatus = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allUsers = widget.viewModel.users;
    final filtered = allUsers.where((u) {
      final role = u['role']?.toString() ?? '';
      final status = u['accountStatus']?.toString() ?? '';
      final name = u['fullName']?.toString().toLowerCase() ?? '';
      final phone = u['phoneNumber']?.toString() ?? '';
      final trx = u['transactionId']?.toString().toLowerCase() ?? '';
      final q = _searchCtrl.text.trim().toLowerCase();

      if (_filterRole.isNotEmpty && role != _filterRole) return false;
      if (_filterStatus.isNotEmpty && status != _filterStatus) return false;
      if (q.isNotEmpty && !name.contains(q) && !phone.contains(q) && !trx.contains(q)) return false;
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFiltersRow(),
        const SizedBox(height: 12),
        if (filtered.isEmpty)
          const Card(child: Padding(padding: EdgeInsets.all(32), child: Center(child: Text('এই ফিল্টারে কোনো সদস্য পাওয়া যায়নি।'))))
        else
          ...filtered.map((u) => _userCard(u as Map<String, dynamic>)),
      ],
    );
  }

  Widget _buildFiltersRow() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(widget.isMobile ? 10 : 14),
        child: Column(
          children: [
            TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(hintText: 'নাম, মোবাইল নম্বর বা TrxID দিয়ে খুঁজুন...', prefixIcon: Icon(Icons.search), isDense: true),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _chip('সকল সদস্য', _filterRole.isEmpty && _filterStatus.isEmpty, () => setState(() { _filterRole = ''; _filterStatus = ''; })),
                  const SizedBox(width: 6),
                  _chip('অপেক্ষমান (Pending)', _filterStatus == 'PAYMENT_SUBMITTED', () => setState(() => _filterStatus = _filterStatus == 'PAYMENT_SUBMITTED' ? '' : 'PAYMENT_SUBMITTED')),
                  const SizedBox(width: 6),
                  _chip('সক্রিয় (Active)', _filterStatus == 'ACTIVE', () => setState(() => _filterStatus = _filterStatus == 'ACTIVE' ? '' : 'ACTIVE')),
                  const SizedBox(width: 6),
                  _chip('বাতিল (Rejected)', _filterStatus == 'REJECTED', () => setState(() => _filterStatus = _filterStatus == 'REJECTED' ? '' : 'REJECTED')),
                  const SizedBox(width: 6),
                  _chip('অফিসার', _filterRole == 'MARKETING_OFFICER', () => setState(() => _filterRole = _filterRole == 'MARKETING_OFFICER' ? '' : 'MARKETING_OFFICER')),
                  const SizedBox(width: 6),
                  _chip('বিক্রেতা', _filterRole == 'SELLER', () => setState(() => _filterRole = _filterRole == 'SELLER' ? '' : 'SELLER')),
                  const SizedBox(width: 6),
                  _chip('ক্রেতা', _filterRole == 'BUYER', () => setState(() => _filterRole = _filterRole == 'BUYER' ? '' : 'BUYER')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, bool sel, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: sel,
      selectedColor: const Color(0xFF0B4F32),
      labelStyle: TextStyle(color: sel ? Colors.white : Colors.black87, fontSize: 11.5, fontWeight: sel ? FontWeight.bold : FontWeight.normal),
      onSelected: (_) => onTap(),
    );
  }

  Widget _userCard(Map<String, dynamic> u) {
    final status = u['accountStatus'] as String? ?? 'PAYMENT_SUBMITTED';
    final isPending = status == 'PAYMENT_SUBMITTED';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: EdgeInsets.all(widget.isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text('${u['fullName']} (${u['role']})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                StatusBadge(status: status),
              ],
            ),
            const SizedBox(height: 4),
            Text('মোবাইল: ${u['phoneNumber']} • এলাকা: ${u['upazila']}, ${u['district']}'),
            const SizedBox(height: 2),
            Text(
              'পেমেন্ট: ${u['paymentMethod']} (প্রেরক: ${u['senderPhone'] ?? '-'}) • TrxID: ${u['transactionId'] ?? '-'}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B4F32), fontSize: 12),
            ),
            if (u['myReferralCode'] != null) Text('অফিসার কোড: ${u['myReferralCode']}', style: const TextStyle(fontSize: 11, color: Colors.blue)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (isPending)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
                    onPressed: () => AdminUserDialogs.showVerifyPaymentDialog(context, user: u, isMobile: widget.isMobile, onSubmit: (app, note) => widget.viewModel.verifyUserPayment(u['id'] as int, app, note)),
                    icon: const Icon(Icons.check_circle, size: 15),
                    label: const Text('পেমেন্ট যাচাই করুন', style: TextStyle(fontSize: 11)),
                  ),
                OutlinedButton.icon(
                  onPressed: () => AdminUserDialogs.showResetPasswordDialog(context, user: u, isMobile: widget.isMobile, onSubmit: (pass) => widget.viewModel.resetUserPassword(u['id'] as int, pass)),
                  icon: const Icon(Icons.lock_reset, size: 15),
                  label: const Text('পাসওয়ার্ড রিসেট', style: TextStyle(fontSize: 11)),
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red.shade800),
                  onPressed: () => AdminUserDialogs.showRefundFeeDialog(context, user: u, isMobile: widget.isMobile, onSubmit: (reason, trx) => widget.viewModel.refundUserFee(u['id'] as int, reason, trx)),
                  icon: const Icon(Icons.money_off, size: 15),
                  label: const Text('ফি রিফান্ড', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
