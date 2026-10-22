import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/core/animations/field_visit_animations.dart';

void main() {
  testWidgets('GpsVehicleMove renders vehicle icon', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: GpsVehicleMove())));
    expect(find.byType(GpsVehicleMove), findsOneWidget);
  });

  testWidgets('VoiceNoteWaveform renders audio wave bars', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: VoiceNoteWaveform())));
    expect(find.byType(VoiceNoteWaveform), findsOneWidget);
  });

  testWidgets('AppointmentCalendarFlip renders date', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: AppointmentCalendarFlip(dayNumber: 24, monthName: 'অক্টোবর'))));
    expect(find.text('24'), findsOneWidget);
  });

  testWidgets('ReadReceiptCheckMorph renders double check', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: ReadReceiptCheckMorph(isRead: true))));
    expect(find.byType(ReadReceiptCheckMorph), findsOneWidget);
  });

  testWidgets('BannerNoticeBounce renders banner notice', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: BannerNoticeBounce(notice: 'নতুন নোটিশ'))));
    expect(find.text('নতুন নোটিশ'), findsOneWidget);
  });

  testWidgets('OfficerStarRatingFill renders stars', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: OfficerStarRatingFill(rating: 4.8))));
    expect(find.byType(OfficerStarRatingFill), findsOneWidget);
  });

  testWidgets('VideoCallHalo renders halo pulse', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: VideoCallHalo())));
    expect(find.byType(VideoCallHalo), findsOneWidget);
  });

  testWidgets('EmojiReactionFloat renders floating emoji', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: EmojiReactionFloat(emoji: '👍'))));
    expect(find.text('👍'), findsOneWidget);
  });

  testWidgets('VisitChecklistCircle renders completed count', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: VisitChecklistCircle(total: 3, completed: 2))));
    expect(find.text('2/3'), findsOneWidget);
  });

  testWidgets('CtaRippleWave renders button with ripple', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: CtaRippleWave(label: 'কল করুন'))));
    expect(find.text('কল করুন'), findsOneWidget);
  });
}
