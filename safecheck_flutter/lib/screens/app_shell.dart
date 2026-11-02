import 'package:flutter/material.dart';
import 'package:safecheck_client/safecheck_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart'
    hide UserProfile;

import '../app_events.dart';
import '../client.dart';
import '../util/errors.dart';
import '../widgets/state_views.dart';
import 'alerts_screen.dart';
import 'about_screen.dart';
import 'contacts_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'trip_screen.dart';

/// Signed-in home. Asks for a profile first, then shows the main tabs.
class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  UserProfile? _profile;
  Object? _error;
  bool _loading = true;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profile = await client.profile.getProfile();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
          'Any active trip keeps running on the server. If you miss its '
          'deadline, an alert is still created.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await client.auth.signOutDevice();
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e), error: true);
    }
  }

  Future<void> _editProfile() async {
    final updated = await Navigator.of(context).push<UserProfile>(
      MaterialPageRoute(builder: (_) => ProfileScreen(existing: _profile)),
    );
    if (updated != null && mounted) {
      setState(() => _profile = updated);
      showSnack(context, 'Profile saved.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: LoadingView(label: 'Loading your profile…'));
    }
    if (_error != null) {
      return Scaffold(
        body: SafeArea(
          child: ErrorView(
            message: friendlyError(_error!),
            onRetry: _loadProfile,
          ),
        ),
      );
    }
    if (_profile == null) {
      return ProfileScreen(
        onboarding: true,
        onSaved: (profile) => setState(() => _profile = profile),
        onSignOut: _signOut,
      );
    }

    const titles = ['SafeCheck', 'Trusted contacts', 'Trip history', 'Alerts'];
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_tab]),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Account',
            icon: const Icon(Icons.account_circle_outlined),
            onSelected: (value) {
              if (value == 'profile') {
                _editProfile();
              } else if (value == 'theme_system') {
                widget.onThemeModeChanged(ThemeMode.system);
              } else if (value == 'theme_light') {
                widget.onThemeModeChanged(ThemeMode.light);
              } else if (value == 'theme_dark') {
                widget.onThemeModeChanged(ThemeMode.dark);
              } else if (value == 'about') {
                openAboutSafeCheck(context);
              } else if (value == 'signout') {
                _signOut();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                enabled: false,
                child: Text(
                  'Signed in as ${_profile!.displayName}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),

              const PopupMenuDivider(),

              const PopupMenuItem<String>(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.edit_outlined),
                  title: Text('Edit profile'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),

              const PopupMenuDivider(),

              const PopupMenuItem<String>(
                enabled: false,
                child: Text(
                  'Appearance',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              PopupMenuItem<String>(
                value: 'theme_system',
                child: ListTile(
                  leading: Icon(
                    widget.themeMode == ThemeMode.system
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                  ),
                  title: const Text('System'),
                  subtitle: const Text('Match device settings'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),

              PopupMenuItem<String>(
                value: 'theme_light',
                child: ListTile(
                  leading: Icon(
                    widget.themeMode == ThemeMode.light
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                  ),
                  title: const Text('Light'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),

              PopupMenuItem<String>(
                value: 'theme_dark',
                child: ListTile(
                  leading: Icon(
                    widget.themeMode == ThemeMode.dark
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                  ),
                  title: const Text('Dark'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),

              const PopupMenuDivider(),

              const PopupMenuItem<String>(
                value: 'about',
                child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('About SafeCheck'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),

              const PopupMenuItem<String>(
                value: 'signout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Sign out'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _tab,
          children: [
            TripScreen(
              onOpenContacts: () => setState(() => _tab = 1),
              onOpenAlerts: () => setState(() => _tab = 3),
            ),
            const ContactsScreen(),
            const HistoryScreen(),
            const AlertsScreen(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) {
          setState(() => _tab = index);
          // Make sure the newly shown tab reflects the latest server state.
          notifyDataChanged();
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.shield_outlined),
            selectedIcon: Icon(Icons.shield),
            label: 'Trip',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Contacts',
          ),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
        ],
      ),
    );
  }
}
