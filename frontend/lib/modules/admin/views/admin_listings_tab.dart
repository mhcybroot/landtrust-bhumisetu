import 'package:flutter/material.dart';
import 'package:landtrust_app/core/widgets/horizontal_scroll_fade_view.dart';
import '../view_models/admin_view_model.dart';
import '../widgets/admin_listing_card.dart';

class AdminListingsTab extends StatefulWidget {
  final AdminViewModel viewModel;
  final bool isMobile;

  const AdminListingsTab({
    super.key,
    required this.viewModel,
    required this.isMobile,
  });

  @override
  State<AdminListingsTab> createState() => _AdminListingsTabState();
}

class _AdminListingsTabState extends State<AdminListingsTab> {
  String _filterStatus = '';

  void _showVerifyDialog(Map<String, dynamic> listing) {
    String status = listing['verificationStatus'] ?? 'FIELD_VERIFIED';
    final notesCtrl = TextEditingController(text: listing['verificationNotes'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('বিজ্ঞাপন যাচাই: ${listing['title']}', style: const TextStyle(fontSize: 16)),
          content: SizedBox(
            width: widget.isMobile ? double.infinity : 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  key: ValueKey('status_$status'),
                  initialValue: status,
                  decoration: const InputDecoration(labelText: 'যাচাইকরণ স্ট্যাটাস', isDense: true),
                  items: const [
                    DropdownMenuItem(value: 'FIELD_VERIFIED', child: Text('🟢 সরেজমিনে যাচাইকৃত (Field Verified)')),
                    DropdownMenuItem(value: 'DOC_CHECKED', child: Text('🔵 প্রাথমিক কাগজপত্র যাচাই (Doc Checked)')),
                    DropdownMenuItem(value: 'SUBMITTED', child: Text('⚪ সাধারণ জমা (Submitted)')),
                    DropdownMenuItem(value: 'REJECTED', child: Text('🔴 বাতিল (Rejected)')),
                  ],
                  onChanged: (v) => setDialogState(() => status = v!),
                ),
                const SizedBox(height: 10),
                TextField(controller: notesCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'যাচাই নোট / মন্তব্য', isDense: true)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
              onPressed: () async {
                await widget.viewModel.verifyListing(listing['id'] as int, status, notesCtrl.text.trim());
                if (mounted && ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('সংরক্ষণ করুন'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _approveListing(Map<String, dynamic> listing) async {
    try {
      await widget.viewModel.approveListing(listing['id'] as int);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('বিজ্ঞাপন ও পেমেন্ট সফলভাবে অনুমোদিত: ${listing['title']}')),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final listings = widget.viewModel.listings.where((l) {
      if (_filterStatus.isNotEmpty && l['verificationStatus'] != _filterStatus) return false;
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilterBar(),
        const SizedBox(height: 12),
        if (listings.isEmpty)
          const Card(child: Padding(padding: EdgeInsets.all(32), child: Center(child: Text('এই ফিল্টারে কোনো বিজ্ঞাপন নেই।'))))
        else
          ...listings.map((l) => AdminListingCard(
                listing: l as Map<String, dynamic>,
                isMobile: widget.isMobile,
                onVerifyTap: () => _showVerifyDialog(l),
                onApproveTap: () => _approveListing(l),
              )),
      ],
    );
  }

  Widget _buildFilterBar() {
    return HorizontalScrollFadeView(
      child: Row(
        children: [
          _chip('সকল বিজ্ঞাপন (${widget.viewModel.listings.length})', _filterStatus.isEmpty, () => setState(() => _filterStatus = '')),
          const SizedBox(width: 6),
          _chip('🟢 সরেজমিনে যাচাইকৃত', _filterStatus == 'FIELD_VERIFIED', () => setState(() => _filterStatus = 'FIELD_VERIFIED')),
          const SizedBox(width: 6),
          _chip('🔵 কাগজপত্র যাচাইকৃত', _filterStatus == 'DOC_CHECKED', () => setState(() => _filterStatus = 'DOC_CHECKED')),
          const SizedBox(width: 6),
          _chip('⚪ সাধারণ জমা', _filterStatus == 'SUBMITTED', () => setState(() => _filterStatus = 'SUBMITTED')),
        ],
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
