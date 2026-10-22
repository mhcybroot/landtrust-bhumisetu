import 'package:flutter/material.dart';

/// ৩১. মাঠ কর্মকর্তা লাইভ জিপিএস ভেহিকেল মুভ (GPS Vehicle Move)
class GpsVehicleMove extends StatelessWidget {
  const GpsVehicleMove({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(5), decoration: const BoxDecoration(color: Color(0xFF0B4F32), shape: BoxShape.circle), child: const Icon(Icons.two_wheeler_rounded, color: Colors.white, size: 16));
  }
}

/// ৩২. ভয়েস নোট অডিও ওয়েভফর্ম (Voice Note Waveform)
class VoiceNoteWaveform extends StatelessWidget {
  const VoiceNoteWaveform({super.key});
  @override
  Widget build(BuildContext context) {
    final heights = [10.0, 16.0, 8.0, 22.0, 14.0, 20.0, 12.0, 18.0];
    return Row(mainAxisSize: MainAxisSize.min, children: heights.map((h) => Container(margin: const EdgeInsets.symmetric(horizontal: 1.5), width: 3, height: h, decoration: BoxDecoration(color: const Color(0xFF0B4F32), borderRadius: BorderRadius.circular(2)))).toList());
  }
}

/// ৩৩. অ্যাপয়েন্টমেন্ট শিডিউল ক্যালেন্ডার ফ্লিপ (Appointment Calendar Flip)
class AppointmentCalendarFlip extends StatelessWidget {
  final int dayNumber; final String monthName;
  const AppointmentCalendarFlip({super.key, required this.dayNumber, required this.monthName});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44, height: 48,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black12)),
      child: Column(children: [
        Container(width: double.infinity, color: const Color(0xFF0B4F32), child: Text(monthName, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold))),
        Expanded(child: Center(child: Text('$dayNumber', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)))),
      ]),
    );
  }
}

/// ৩৪. মেসেজ সিন ডাবল চেক ব্লু মর্ফ (Read Receipt Check Morph)
class ReadReceiptCheckMorph extends StatelessWidget {
  final bool isRead;
  const ReadReceiptCheckMorph({super.key, required this.isRead});
  @override
  Widget build(BuildContext context) {
    return Icon(Icons.done_all_rounded, color: isRead ? const Color(0xFF1E88E5) : Colors.grey.shade400, size: 16);
  }
}

/// ৩৫. টপ ইনকোয়ারি ব্যানার বাউন্স (Banner Notice Bounce)
class BannerNoticeBounce extends StatelessWidget {
  final String notice;
  const BannerNoticeBounce({super.key, required this.notice});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFFD8F3DC), borderRadius: BorderRadius.circular(8)),
      child: Text(notice, style: const TextStyle(color: Color(0xFF0B4F32), fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}

/// ৩৬. অফিসার স্টার রেটিং ফিল (Officer Star Rating Fill)
class OfficerStarRatingFill extends StatelessWidget {
  final double rating;
  const OfficerStarRatingFill({super.key, required this.rating});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 16),
      const SizedBox(width: 3),
      Text(rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
    ]);
  }
}

/// ৩৭. ভিডিও কল রিংগিং হ্যালো পালস (Video Call Halo)
class VideoCallHalo extends StatelessWidget {
  const VideoCallHalo({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF10B981).withValues(alpha: 0.2)),
      child: const Icon(Icons.videocam_rounded, color: Color(0xFF047857), size: 20),
    );
  }
}

/// ৩৮. ফিডব্যাক ইমোজি ফ্লোট (Emoji Reaction Float)
class EmojiReactionFloat extends StatelessWidget {
  final String emoji;
  const EmojiReactionFloat({super.key, required this.emoji});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
      child: Text(emoji, style: const TextStyle(fontSize: 16)),
    );
  }
}

/// ৩৯. সরেজমিন পরিদর্শন চেকলিস্ট সার্কেল (Visit Checklist Circle)
class VisitChecklistCircle extends StatelessWidget {
  final int total; final int completed;
  const VisitChecklistCircle({super.key, required this.total, required this.completed});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
      child: Text('$completed/$total', style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }
}

/// ৪০. সিটিএ বাটন রিপল ওয়েভ (CTA Ripple Wave)
class CtaRippleWave extends StatelessWidget {
  final String label;
  const CtaRippleWave({super.key, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFF0B4F32), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}
