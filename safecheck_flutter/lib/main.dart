import 'package:flutter/material.dart';

import 'client.dart';
import 'screens/app_shell.dart';
import 'screens/sign_in_screen.dart';
import 'theme/safecheck_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeClient();
  runApp(const SafeCheckApp());
}

class SafeCheckApp extends StatefulWidget {
  const SafeCheckApp({super.key});

  @override
  State<SafeCheckApp> createState() => _SafeCheckAppState();
}

class _SafeCheckAppState extends State<SafeCheckApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeCheck AI',
      debugShowCheckedModeBanner: false,
      theme: SafeCheckTheme.build(Brightness.light),
      darkTheme: SafeCheckTheme.build(Brightness.dark),
      themeMode: _themeMode,
      home: SignInScreen(
        child: AppShell(
          themeMode: _themeMode,
          onThemeModeChanged: _setThemeMode,
        ),
      ),
    );
  }
}
