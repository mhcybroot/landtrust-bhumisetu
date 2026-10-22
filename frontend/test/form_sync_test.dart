import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/core/constants/app_constants.dart';
import 'package:landtrust_app/core/localization/app_language.dart';
import 'package:landtrust_app/core/localization/app_strings.dart';
import 'package:landtrust_app/core/localization/locale_notifier.dart';
import 'package:landtrust_app/core/session/session_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocaleNotifier.instance.setLanguage(AppLanguage.bn);
    await SessionManager.instance.clearSession();
  });

  group('AppConstants support credentials', () {
    test('contains valid canonical support credentials', () {
      expect(AppConstants.defaultSupportPhone.isNotEmpty, isTrue);
      expect(AppConstants.defaultSupportWhatsapp.isNotEmpty, isTrue);
      expect(AppConstants.defaultSupportEmail.contains('@'), isTrue);
      expect(AppConstants.defaultSupportEmail.contains('.'), isTrue);
      expect(AppConstants.defaultOfficeAddress.isNotEmpty, isTrue);
    });
  });

  group('AppStrings localization & fallbacks', () {
    test('app_title returns bdHousing for both Bengali and English locales', () async {
      await LocaleNotifier.instance.setLanguage(AppLanguage.bn);
      expect(AppStrings.tr('app_title'), 'bdHousing');

      await LocaleNotifier.instance.setLanguage(AppLanguage.en);
      expect(AppStrings.tr('app_title'), 'bdHousing');
    });

    test('returns key itself when translation is missing', () {
      expect(AppStrings.tr('non_existent_key_xyz'), 'non_existent_key_xyz');
    });
  });

  group('Form field key stability and synchronization', () {
    test('cascading dropdown keys change reliably when parent changes', () {
      const distA = 'Dhaka';
      const distB = 'Chittagong';
      const upz = 'Sadar';

      final keyA = ValueKey('reg_upz_${distA}_$upz');
      final keyB = ValueKey('reg_upz_${distB}_$upz');
      final keyASame = ValueKey('reg_upz_${distA}_$upz');

      expect(keyA, equals(keyASame));
      expect(keyA, isNot(equals(keyB)));
    });

    testWidgets('dropdown with dynamic ValueKey updates selection stably', (tester) async {
      String district = 'নোয়াখালী';
      final items = ['নোয়াখালী', 'কুমিল্লা', 'ফেনী'];

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButtonFormField<String>(
                key: ValueKey('dist_$district'),
                initialValue: district,
                items: items
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (val) {
                  setState(() => district = val!);
                },
              );
            },
          ),
        ),
      ));

      expect(find.text('নোয়াখালী'), findsOneWidget);
      await tester.tap(find.text('নোয়াখালী'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('ফেনী').last);
      await tester.pumpAndSettle();

      expect(find.text('ফেনী'), findsOneWidget);
      expect(district, 'ফেনী');
    });
  });

  group('SessionManager state synchronization', () {
    test('manages session persistence and roles safely', () async {
      final session = SessionManager.instance;
      expect(session.isAuthenticated, isFalse);

      await session.saveSession('test-token-123', {
        'id': 1,
        'name': 'Test User',
        'role': 'ADMIN',
      });

      expect(session.isAuthenticated, isTrue);
      expect(session.isAdmin, isTrue);
      expect(session.userRole, 'ADMIN');

      await session.clearSession();
      expect(session.isAuthenticated, isFalse);
      expect(session.currentUser, isNull);
    });
  });
}
