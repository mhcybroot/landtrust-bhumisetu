import 'package:flutter/material.dart';
import 'package:landtrust_app/core/widgets/horizontal_scroll_fade_view.dart';
import '../view_models/admin_view_model.dart';
import '../widgets/admin_communication_dialogs.dart';
import '../widgets/admin_user_card.dart';

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
          ...filtered.map((u) => AdminUserCard(
                user: u as Map<String, dynamic>,
                viewModel: widget.viewModel,
                isMobile: widget.isMobile,
              )),
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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: const InputDecoration(hintText: 'নাম, মোবাইল নম্বর বা TrxID দিয়ে খুঁজুন...', prefixIcon: Icon(Icons.search), isDense: true),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B4F32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  ),
                  onPressed: () => AdminCommunicationDialogs.showBroadcastNotificationDialog(
                    context,
                    isMobile: widget.isMobile,
                    onSubmit: (t, m, r) => widget.viewModel.broadcastNotification(t, m, role: r),
                  ),
                  icon: const Icon(Icons.campaign, size: 16),
                  label: const Text('ব্রডকাস্ট', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            HorizontalScrollFadeView(
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
}
