import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safecheck_flutter/widgets/copy_tracking_link_button.dart';

void main() {
  testWidgets('copies the stored tracking URL exactly and confirms success', (
    tester,
  ) async {
    const url = 'http://localhost:8082/t/aB0_OIl-9z%41?source=alert';
    const body =
        'Trip description: "https://example.com/t/another-token". '
        'Please try to reach them. View their live or last known location '
        'and trip route: $url';
    final copied = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied.add((call.arguments as Map)['text'] as String);
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CopyTrackingLinkButton(messageBody: body),
        ),
      ),
    );
    await tester.tap(find.text('Copy tracking link'));
    await tester.pump();
    expect(copied, [url]);
    expect(find.text('Tracking link copied.'), findsOneWidget);
  });

  testWidgets('messages without a tracking URL have no copy button', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CopyTrackingLinkButton(
            messageBody:
                'SafeCheck alert. Please try to reach them. https://example.com/help',
          ),
        ),
      ),
    );
    expect(find.text('Copy tracking link'), findsNothing);
  });

  testWidgets(
    'clipboard failure reports failure without claiming it was copied',
    (tester) async {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            throw PlatformException(code: 'clipboard_denied');
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CopyTrackingLinkButton(
              messageBody:
                  'View location: https://example.com/t/unchanged-token',
            ),
          ),
        ),
      );
      await tester.tap(find.text('Copy tracking link'));
      await tester.pump();
      expect(
        find.text('Could not copy tracking link. Please try again.'),
        findsOneWidget,
      );
      expect(find.text('Tracking link copied.'), findsNothing);
    },
  );
}
