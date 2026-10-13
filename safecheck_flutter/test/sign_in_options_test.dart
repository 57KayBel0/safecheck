import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safecheck_client/safecheck_client.dart';
import 'package:safecheck_flutter/auth/remember_me_storage.dart';
import 'package:safecheck_flutter/auth/session_manager.dart';
import 'package:safecheck_flutter/client.dart' as app;
import 'package:safecheck_flutter/screens/sign_in_screen.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

class MemoryAuthStorage implements ClientAuthSuccessStorage {
  AuthSuccess? value;

  @override
  Future<AuthSuccess?> get() async => value;

  @override
  Future<void> set(AuthSuccess? data) async => value = data;
}

class MemoryKeyValueStorage implements RememberMeKeyValueStorage {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String? value) async {
    if (value == null) {
      values.remove(key);
    } else {
      values[key] = value;
    }
  }
}

final rememberStorage = RememberMeAuthSuccessStorage(
  persistentAuthStorage: MemoryAuthStorage(),
  keyValueStorage: MemoryKeyValueStorage(),
);
final fakeClient = Client(
  'http://localhost:1/',
)..authSessionManager = createSafeCheckSessionManager(storage: rememberStorage);

void main() {
  app.client = fakeClient;

  setUp(() async {
    await rememberStorage.setRememberMe(false);
    await rememberStorage.set(null);
  });

  testWidgets('restores a remembered email in the responsive login form', (
    tester,
  ) async {
    await rememberStorage.setRememberMe(true);
    await rememberStorage.rememberEmailAfterSignIn('person@example.com');

    await tester.pumpWidget(
      const MaterialApp(
        home: SignInScreen(
          googleSignInConfigured: false,
          child: Text('Private content'),
        ),
      ),
    );
    final emailField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.keyboardType == TextInputType.emailAddress,
    );
    var restoredEmail = '';
    for (var frame = 0; frame < 5; frame++) {
      await tester.pump();
      if (emailField.evaluate().isNotEmpty) {
        restoredEmail = tester.widget<TextField>(emailField).controller!.text;
        if (restoredEmail == 'person@example.com') break;
      }
    }
    expect(emailField, findsOneWidget);
    expect(restoredEmail, 'person@example.com');
    expect(
      tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
      isFalse,
    );

    // The SDK debounces email validation for 500 ms when restoration updates
    // its controller. Advance fake time before disposing the owned controller.
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'remember checkbox defaults off and Google is visibly unavailable',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SignInScreen(
            googleSignInConfigured: false,
            child: Text('Private content'),
          ),
        ),
      );

      expect(find.text('Remember me on this device'), findsOneWidget);
      final checkbox = tester.widget<CheckboxListTile>(
        find.byType(CheckboxListTile),
      );
      expect(checkbox.value, isFalse);
      expect(find.text('Use only on a device you trust.'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(
        tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
        isNull,
      );
      expect(
        find.text('Google sign-in is unavailable until OAuth is configured.'),
        findsOneWidget,
      );
      expect(find.text('Already have an account?'), findsOneWidget);
    },
  );

  testWidgets(
    'About and third-party licences are accessible without signing in',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SignInScreen(
            googleSignInConfigured: false,
            child: Text('Private content'),
          ),
        ),
      );
      await tester.ensureVisible(find.text('About SafeCheck'));
      await tester.tap(find.text('About SafeCheck'));
      await tester.pumpAndSettle();
      expect(find.text('Privacy policy'), findsOneWidget);
      expect(find.text('Kabelo Motshabi Makgae'), findsOneWidget);
      expect(find.textContaining('Demo — SMS not sent.'), findsOneWidget);

      await tester.ensureVisible(find.text('Third-party licences'));
      await tester.tap(find.text('Third-party licences'));
      await tester.pumpAndSettle();
      expect(find.byType(LicensePage), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Remember me on this device'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Private content'), findsNothing);
      expect(find.text('Privacy policy'), findsOneWidget);
    },
  );

  testWidgets(
    'Google provider errors show feedback without removing email login',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SignInScreen(
            googleSignInConfigured: false,
            child: Text('Private content'),
          ),
        ),
      );

      reportGoogleSignInError(
        tester.element(find.byType(SignInScreen)),
        Exception('provider unavailable'),
      );
      await tester.pump();

      expect(find.textContaining('Google sign-in failed:'), findsOneWidget);
      expect(find.text('Already have an account?'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
    },
  );
}
