import 'package:flutter/material.dart';
import 'package:safecheck_client/safecheck_client.dart' as safecheck;
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../client.dart';
import '../widgets/responsive_email_sign_in.dart';
import '../widgets/state_views.dart';
import '../widgets/privacy_policy_link.dart';
import 'about_screen.dart';

/// Shows the email sign-in / sign-up flow until the user is authenticated,
/// then shows [child].
class SignInScreen extends StatefulWidget {
  final Widget child;
  final bool? googleSignInConfigured;
  const SignInScreen({
    super.key,
    required this.child,
    this.googleSignInConfigured,
  });

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _isSignedIn = false;

  @override
  void initState() {
    super.initState();
    client.auth.authInfoListenable.addListener(_updateSignedInState);
    _isSignedIn = client.auth.isAuthenticated;
  }

  @override
  void dispose() {
    client.auth.authInfoListenable.removeListener(_updateSignedInState);
    super.dispose();
  }

  void _updateSignedInState() {
    setState(() {
      _isSignedIn = client.auth.isAuthenticated;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isSignedIn) return widget.child;

    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.shield_moon, size: 64, color: colors.primary),
                  const SizedBox(height: 12),
                  Text(
                    'SafeCheck',
                    style: text.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Set a check-in time before you travel. If you miss it, '
                    'SafeCheck raises an alert for your trusted contacts.',
                    style: text.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SignInWidget(
                    client: client,
                    disableGoogleSignInWidget: true,
                    emailSignInWidget: ResponsiveEmailSignInWidget(
                      client: client,
                      onAuthenticated: () => showSnack(
                        context,
                        'Signed in. Welcome to SafeCheck.',
                      ),
                      onError: (error) => showSnack(
                        context,
                        'Sign-in failed: $error',
                        error: true,
                      ),
                    ),
                    onAuthenticated: () =>
                        showSnack(context, 'Signed in. Welcome to SafeCheck.'),
                    onError: (error) => showSnack(
                      context,
                      'Sign-in failed: $error',
                      error: true,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'Or continue with',
                          style: text.bodySmall,
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _GoogleSignInOption(
                    client: client,
                    configured:
                        widget.googleSignInConfigured ?? googleSignInReady,
                    onAuthenticated: () => showSnack(
                      context,
                      'Signed in. Welcome to SafeCheck.',
                    ),
                    onError: (error) => reportGoogleSignInError(context, error),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => openAboutSafeCheck(context),
                    child: const Text('About SafeCheck'),
                  ),
                  const PrivacyPolicyLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Keeps the Google action visible even before OAuth credentials are set up.
class _GoogleSignInOption extends StatelessWidget {
  const _GoogleSignInOption({
    required this.client,
    required this.configured,
    required this.onAuthenticated,
    required this.onError,
  });

  final safecheck.Client client;
  final bool configured;
  final VoidCallback onAuthenticated;
  final void Function(Object error) onError;

  @override
  Widget build(BuildContext context) {
    if (configured) {
      return GoogleSignInWidget(
        client: client,
        scopes: const [
          'openid',
          'https://www.googleapis.com/auth/userinfo.email',
          'https://www.googleapis.com/auth/userinfo.profile',
        ],
        onAuthenticated: onAuthenticated,
        onError: onError,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.g_mobiledata),
          label: const Text('Continue with Google'),
        ),
        const SizedBox(height: 4),
        Text(
          'Google sign-in is unavailable until OAuth is configured.',
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

void reportGoogleSignInError(BuildContext context, Object error) {
  showSnack(context, 'Google sign-in failed: $error', error: true);
}
