import 'package:flutter/material.dart';
import 'package:landtrust_app/core/animations/bouncing_pressable.dart';
import 'package:landtrust_app/core/utils/communication_utils.dart';
import 'package:landtrust_app/core/widgets/status_badge.dart';
import '../view_models/admin_view_model.dart';

class AdminDemandsInquiriesTab extends StatefulWidget {
  final AdminViewModel viewModel;
  final bool isMobile;

  const AdminDemandsInquiriesTab({
    super.key,
    required this.viewModel,
    required this.isMobile,
  });

  @override
  State<AdminDemandsInquiriesTab> createState() => _AdminDemandsInquiriesTabState();
}

class _AdminDemandsInquiriesTabState extends State<AdminDemandsInquiriesTab> {
  bool _showInquiries = false;

  @override
  Widget build(BuildContext context) {
    final reqs = widget.viewModel.requirements;
    final inqs = widget.viewModel.inquiries;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(
          child: BouncingPressable(
            onTap: () => setState(() => _showInquiries = false),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: !_showInquiries ? const Color(0xFF0B4F32) : Colors.grey.shade200,
                foregroundColor: !_showInquiries ? Colors.white : Colors.black87,
              ),
              onPressed: () => setState(() => _showInquiries = false),
              child: Text('ক্রেতার চাহিদা (${reqs.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: BouncingPressable(
            onTap: () => setState(() => _showInquiries = true),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _showInquiries ? const Color(0xFF0B4F32) : Colors.grey.shade200,
                foregroundColor: _showInquiries ? Colors.white : Colors.black87,
              ),
              onPressed: () => setState(() => _showInquiries = true),
              child: Text('আগ্রহ প্রকাশ / ইনকোয়ারি (${inqs.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
        ),
      ]),
      const SizedBox(height: 12),
      if (!_showInquiries) _buildDemandsList(reqs) else _buildInquiriesList(inqs),
    ]);
  }

  Widget _buildDemandsList(List<dynamic> reqs) {
    if (reqs.isEmpty) return const Card(child: Padding(padding: EdgeInsets.all(32), child: Center(child: Text('কোনো ক্রেতার চাহিদা পাওয়া যায়নি।'))));
    return Column(
      children: reqs.map((r) {
        final isVerified = r['status'] == 'VERIFIED' || r['status'] == 'ACTIVE';
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: EdgeInsets.all(widget.isMobile ? 12 : 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(child: Text('${r['preferredUpazila']}, ${r['preferredDistrict']} (${r['landType']})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5))),
                StatusBadge(status: r['status']),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                Expanded(child: Text('ক্রেতা: ${r['buyerName']} • মোবাইল: ${r['buyerPhone']}')),
                BouncingPressable(
                  onTap: () => CommunicationUtils.openDemandInquiryChat(phone: r['buyerPhone']?.toString() ?? '', userName: r['buyerName']?.toString() ?? '', demandTitle: '${r['preferredUpazila']}, ${r['preferredDistrict']}'),
                  child: const Icon(Icons.chat, size: 16, color: Color(0xFF25D366)),
                ),
                const SizedBox(width: 8),
                BouncingPressable(
                  onTap: () => CommunicationUtils.makePhoneCall(r['buyerPhone']?.toString() ?? ''),
                  child: const Icon(Icons.phone, size: 16, color: Colors.blue),
                ),
              ]),
              const SizedBox(height: 2),
              Text('বাজেট: ৳${r['minBudgetBdt']}–৳${r['maxBudgetBdt']} • পরিমাণ: ${r['minAreaDecimal']}–${r['maxAreaDecimal']} শতাংশ', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B4F32))),
              const SizedBox(height: 10),
              Wrap(spacing: 8, children: [
                if (!isVerified)
                  BouncingPressable(
                    onTap: () => widget.viewModel.verifyRequirement(r['id'] as int, true),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
                      onPressed: () => widget.viewModel.verifyRequirement(r['id'] as int, true),
                      icon: const Icon(Icons.check, size: 15),
                      label: const Text('অনুমোদন করুন', style: TextStyle(fontSize: 11)),
                    ),
                  ),
                BouncingPressable(
                  onTap: () => widget.viewModel.verifyRequirement(r['id'] as int, false),
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    onPressed: () => widget.viewModel.verifyRequirement(r['id'] as int, false),
                    icon: const Icon(Icons.close, size: 15),
                    label: const Text('বাতিল করুন', style: TextStyle(fontSize: 11)),
                  ),
                ),
              ]),
            ]),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInquiriesList(List<dynamic> inqs) {
    if (inqs.isEmpty) return const Card(child: Padding(padding: EdgeInsets.all(32), child: Center(child: Text('কোনো ইনকোয়ারি পাওয়া যায়নি।'))));
    return Column(
      children: inqs.map((inq) {
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: EdgeInsets.all(widget.isMobile ? 12 : 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(child: Text(inq['listingTitle'] ?? 'জমির ইনকোয়ারি', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                StatusBadge(status: inq['status']),
              ]),
              const SizedBox(height: 4),
              Text('আগ্রহী ক্রেতা: ${inq['buyerName']} (${inq['buyerPhone']})'),
              const SizedBox(height: 2),
              Text('বিক্রেতা: ${inq['sellerName']} (${inq['sellerPhone']})'),
              const SizedBox(height: 2),
              Text('প্রস্তাবিত বাজেট: ৳${inq['offeredBudgetBdt']} • বার্তা: ${inq['message']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B4F32), fontSize: 12)),
              const SizedBox(height: 6),
              Wrap(spacing: 8, children: [
                BouncingPressable(
                  onTap: () => CommunicationUtils.launchWhatsApp(phone: inq['buyerPhone']?.toString() ?? '', message: 'আসসালামু আলাইকুম ${inq['buyerName']}, LandApp-এ আপনার ইনকোয়ারি সংক্রান্ত বিষয়ে যোগাযোগ করছি।'),
                  child: TextButton.icon(
                    style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                    icon: const Icon(Icons.chat, size: 14, color: Color(0xFF25D366)),
                    label: Text('ক্রেতা (${inq['buyerName']}) WhatsApp', style: const TextStyle(fontSize: 10.5, color: Color(0xFF075E54))),
                    onPressed: () => CommunicationUtils.launchWhatsApp(phone: inq['buyerPhone']?.toString() ?? '', message: 'আসসালামু আলাইকুম ${inq['buyerName']}, LandApp-এ আপনার ইনকোয়ারি সংক্রান্ত বিষয়ে যোগাযোগ করছি।'),
                  ),
                ),
                BouncingPressable(
                  onTap: () => CommunicationUtils.makePhoneCall(inq['buyerPhone']?.toString() ?? ''),
                  child: TextButton.icon(
                    style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                    icon: const Icon(Icons.phone, size: 14, color: Colors.blue),
                    label: const Text('কল দিন', style: TextStyle(fontSize: 10.5, color: Colors.blue)),
                    onPressed: () => CommunicationUtils.makePhoneCall(inq['buyerPhone']?.toString() ?? ''),
                  ),
                ),
              ]),
            ]),
          ),
        );
      }).toList(),
    );
  }
}
