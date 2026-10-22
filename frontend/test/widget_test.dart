import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/main.dart';

void main() {
  testWidgets('LandTrustApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const LandTrustApp());
    expect(find.textContaining('bdHousing'), findsWidgets);
  });
}
