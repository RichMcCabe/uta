import 'package:flutter_test/flutter_test.dart';
import 'package:uta/main.dart';

void main() {
  testWidgets('UTA app boots', (WidgetTester tester) async {
    await tester.pumpWidget(const UtaApp());

    expect(find.text('Ultimate Travel App'), findsWidgets);
    expect(find.text('Orlando Adventure'), findsOneWidget);
  });
}
