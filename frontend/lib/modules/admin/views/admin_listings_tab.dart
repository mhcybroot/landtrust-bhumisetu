import 'package:flutter/material.dart';
import 'package:landtrust_app/core/widgets/horizontal_scroll_fade_view.dart';
import 'package:landtrust_app/core/widgets/smart_image_viewer.dart';
import 'package:landtrust_app/core/widgets/status_badge.dart';
import 'package:landtrust_app/modules/member_portal/widgets/private_document_preview_dialog.dart';
import '../view_models/admin_view_model.dart';

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
                  value: status,
                  decoration: const InputDecoration(labelText: 'যাচাইকরণ স্ট্যাটাস', isDense: true),
                  items: [
                    const DropdownMenuItem(value: 'FIELD_VERIFIED', child: Text('🟢 সরেজমিনে যাচাইকৃত (Field Verified)')),
                    const DropdownMenuItem(value: 'DOC_CHECKED', child: Text('🔵 প্রাথমিক কাগজপত্র যাচাই (Doc Checked)')),
                    const DropdownMenuItem(value: 'SUBMITTED', child: Text('⚪ সাধারণ জমা (Submitted)')),
                    const DropdownMenuItem(value: 'REJECTED', child: Text('🔴 বাতিল (Rejected)')),
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
          ...listings.map((l) => _listingCard(l as Map<String, dynamic>)),
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

  Widget _listingCard(Map<String, dynamic> l) {
    final hasDoc = l['privateDocumentUrl'] != null && l['privateDocumentUrl'].toString().isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(widget.isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SmartImageViewer(url: l['imageUrl'] as String?, height: widget.isMobile ? 65 : 75, width: widget.isMobile ? 85 : 100),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Wrap(spacing: 6, runSpacing: 4, children: [
                        VerificationBadge(status: l['verificationStatus']),
                        StatusBadge(status: l['listingStatus']),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('অবস্থান: ${l['areaName']}, ${l['upazila']}, ${l['district']} • মৌজা: ${l['mouzaName'] ?? '-'}'),
            const SizedBox(height: 2),
            Text('পরিমাণ: ${l['areaDecimal']} শতাংশ • মূল্য: ৳${l['expectedPriceBdt']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B4F32))),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
                  onPressed: () => _showVerifyDialog(l),
                  icon: const Icon(Icons.verified, size: 15),
                  label: const Text('যাচাইকরণ পরিবর্তন', style: TextStyle(fontSize: 11)),
                ),
                if (hasDoc)
                  OutlinedButton.icon(
                    onPressed: () => PrivateDocumentPreviewDialog.show(context, listing: l, isMobile: widget.isMobile),
                    icon: const Icon(Icons.description, size: 15),
                    label: const Text('দলিল প্রিভিউ', style: TextStyle(fontSize: 11)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
