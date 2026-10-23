import 'package:flutter/material.dart';
import 'package:landtrust_app/core/animations/bouncing_pressable.dart';
import 'package:landtrust_app/core/animations/sheen_sweep_effect.dart';

class NrbRequestCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final bool isMobile;

  const NrbRequestCard({super.key, required this.request, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final status = request['poaStatus']?.toString() ?? 'SUBMITTED';
    final serviceType = request['serviceType']?.toString() ?? 'INSTITUTIONAL_REPRESENTATION';
    final district = request['district'] ?? '';
    final upazila = request['upazila'] ?? '';
    final country = request['countryOfResidence'] ?? '';
    final area = request['landAreaDecimal']?.toString() ?? '0';
    final price = request['askingPriceBdt']?.toString() ?? '0';
    final agent = request['assignedAgentName'];
    final adminNote = request['adminNotes'];

    final statusInfo = switch (status) {
      'SUBMITTED' => (label: 'আবেদন জমা হয়েছে', color: Colors.blue),
      'UNDER_LEGAL_REVIEW' => (label: 'আইনি যাচাই চলছে', color: Colors.orange),
      'EMBASSY_DRAFT_READY' => (label: 'দূতাবাস ড্রাফট প্রস্তুত', color: Colors.purple),
      'ATTESTED' => (label: 'দূতাবাসে সত্যায়িত', color: Colors.teal),
      'REGISTERED' => (label: 'অনুমোদিত ও সক্রিয়', color: Colors.green),
      'REJECTED' => (label: 'বাতিল', color: Colors.red),
      _ => (label: status, color: Colors.grey),
    };

    final serviceLabel = serviceType == 'POWER_OF_ATTORNEY' ? 'পাওয়ার অব অ্যাটর্নি (PoA)' : 'প্রাতিষ্ঠানিক প্রতিনিধি';

    return BouncingPressable(
      onTap: () {},
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(6)),
                    child: Text(serviceLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: Color(0xFF0B4F32))),
                  ),
                  SheenSweepEffect(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: statusInfo.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text(statusInfo.label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: statusInfo.color)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text('📍 প্রপার্টি অবস্থান: $upazila, $district', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text('🌍 প্রবাসীর দেশ: $country  •  জমির পরিমাণ: $area শতক  •  মূল্য: ৳$price', style: const TextStyle(fontSize: 12, color: Colors.black87)),
              if (agent != null && agent.toString().isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.person_pin, size: 15, color: Color(0xFF0B4F32)),
                  const SizedBox(width: 4),
                  Text('মনোনীত প্রতিনিধি: $agent', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF0B4F32))),
                ]),
              ],
              if (adminNote != null && adminNote.toString().isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(6)),
                  child: Text('অ্যাডমিন নোট: $adminNote', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
