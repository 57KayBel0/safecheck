import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'check_in_reminder.dart';

bool reminderModeSupported(CheckInReminderMode mode) {
  if (kIsWeb) return mode == CheckInReminderMode.silent;

  return switch (mode) {
    CheckInReminderMode.silent => true,
    CheckInReminderMode.vibration =>
      defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS,
    CheckInReminderMode.sound =>
      defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows,
  };
}

Future<void> playReminderFeedback(CheckInReminderMode mode) async {
  if (!reminderModeSupported(mode)) return;
  switch (mode) {
    case CheckInReminderMode.silent:
      return;
    case CheckInReminderMode.vibration:
      return HapticFeedback.vibrate();
    case CheckInReminderMode.sound:
      return SystemSound.play(SystemSoundType.alert);
  }
}
