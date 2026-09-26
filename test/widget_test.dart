import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextcue/main.dart';

void main() {
  const channel = MethodChannel('app.nextcue/share-evidence');

  testWidgets('shows content-free durable import status', (tester) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'getImportStatus');
          return <String, Object?>{
            'status': 'idle',
            'pendingCount': 0,
            'captureCount': 2,
            'importedCount': 0,
          };
        });

    await tester.pumpWidget(const NextCueHarness());
    await tester.pumpAndSettle();

    expect(find.text('Durable import status'), findsOneWidget);
    expect(find.textContaining('status: idle'), findsOneWidget);
    expect(find.textContaining('captureCount: 2'), findsOneWidget);
    expect(find.text('Retry import'), findsOneWidget);
    expect(find.text('Simulate optional failure'), findsOneWidget);
  });

  testWidgets('retry requests a fresh native import', (tester) async {
    var retryCount = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'retryImport') retryCount += 1;
          return <String, Object?>{
            'status': call.method == 'retryImport' ? 'imported' : 'idle',
            'pendingCount': 0,
            'captureCount': retryCount,
            'importedCount': retryCount,
          };
        });

    await tester.pumpWidget(const NextCueHarness());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Retry import'));
    await tester.pumpAndSettle();

    expect(retryCount, 1);
    expect(find.textContaining('status: imported'), findsOneWidget);
  });
}
