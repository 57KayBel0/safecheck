import 'package:flutter/foundation.dart';

/// Bumped whenever data shown on several tabs may have changed (a trip
/// started or ended, contacts changed), so other tabs know to reload.
final dataRevision = ValueNotifier<int>(0);

void notifyDataChanged() => dataRevision.value++;
