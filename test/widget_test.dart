import 'package:flutter_test/flutter_test.dart';
import 'package:nextcue/main.dart';

void main() {
  testWidgets('shows only sanitized evidence surface', (tester) async {
    await tester.pumpWidget(const NextCueHarness());
    await tester.pumpAndSettle();

    expect(find.text('Sanitized share evidence'), findsOneWidget);
    expect(find.text('No share evidence recorded.'), findsOneWidget);
    expect(find.text('Refresh evidence'), findsOneWidget);
  });
}
