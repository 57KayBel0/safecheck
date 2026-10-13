// Reuse the SDK's form controls; only the two account-navigation layouts are
// app-owned because the SDK forms do not expose a footer builder.
// ignore_for_file: implementation_imports
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:serverpod_auth_idp_flutter/src/common/widgets/buttons/action_button.dart';
import 'package:serverpod_auth_idp_flutter/src/common/widgets/password_field.dart';
import 'package:serverpod_auth_idp_flutter/src/email/forms/widgets/email_text_field.dart';

import '../auth/remember_me_storage.dart';

/// Keeps the SDK email flow while allowing account prompts to wrap on phones.
class ResponsiveEmailSignInWidget extends EmailSignInWidget {
  const ResponsiveEmailSignInWidget({
    required super.client,
    super.onAuthenticated,
    super.onError,
    super.key,
  });

  @override
  State<ResponsiveEmailSignInWidget> createState() =>
      _ResponsiveEmailSignInWidgetState();
}

class _ResponsiveEmailSignInWidgetState
    extends State<ResponsiveEmailSignInWidget> {
  late final EmailAuthController _controller;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _controller = EmailAuthController(
      client: widget.client!,
      startScreen: widget.startScreen,
      onAuthenticated: _handleAuthenticated,
      onError: widget.onError,
    )..addListener(_refresh);
    unawaited(_restoreRememberedEmail());
  }

  void _refresh() => setState(() {});

  Future<void> _handleAuthenticated() async {
    final storage = widget.client!.auth.storage;
    if (storage is RememberMeAuthSuccessStorage) {
      await storage.rememberEmailAfterSignIn(
        _controller.emailController.text.trim(),
      );
    }
    widget.onAuthenticated?.call();
  }

  void _setRememberMe(bool selected) {
    setState(() => _rememberMe = selected);
    final storage = widget.client!.auth.storage;
    if (storage is RememberMeAuthSuccessStorage) {
      unawaited(storage.setRememberMe(selected));
    }
  }

  Future<void> _restoreRememberedEmail() async {
    final storage = widget.client!.auth.storage;
    if (storage is! RememberMeAuthSuccessStorage) return;
    final email = await storage.getRememberedEmail();
    if (mounted && email != null && _controller.emailController.text.isEmpty) {
      _controller.emailController.text = email;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screen = _controller.currentScreen;
    if (screen != EmailFlowScreen.login &&
        screen != EmailFlowScreen.startRegistration) {
      return EmailSignInWidget(controller: _controller);
    }

    final texts = context.emailSignInTexts;
    final login = screen == EmailFlowScreen.login;
    final canSubmit =
        _controller.state == EmailAuthState.idle &&
        _controller.emailController.text.isNotEmpty &&
        (!login || _controller.passwordController.text.isNotEmpty);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          login ? texts.title : texts.signUpTitle,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 24),
        EmailTextField(controller: _controller),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: _rememberMe,
          onChanged: (selected) => _setRememberMe(selected ?? false),
          title: const Text('Remember me on this device'),
          subtitle: const Text('Use only on a device you trust.'),
        ),
        if (login) ...[
          const SizedBox(height: 16),
          PasswordField(
            controller: _controller.passwordController,
            isLoading: _controller.isLoading,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _controller.navigateTo(
                EmailFlowScreen.requestPasswordReset,
              ),
              child: Text(texts.forgotPassword),
            ),
          ),
        ],
        const SizedBox(height: 24),
        ActionButton(
          onPressed: canSubmit
              ? () => unawaited(
                  login ? _controller.login() : _controller.startRegistration(),
                )
              : null,
          label: login ? texts.signIn : texts.continueAction,
          isLoading: _controller.isLoading,
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          children: [
            Text(
              login ? texts.dontHaveAnAccount : texts.alreadyHaveAnAccount,
              textAlign: TextAlign.center,
            ),
            TextButton(
              onPressed: () => _controller.navigateTo(
                login
                    ? EmailFlowScreen.startRegistration
                    : EmailFlowScreen.login,
              ),
              child: Text(login ? texts.signUp : texts.signIn),
            ),
          ],
        ),
      ],
    );
  }
}
