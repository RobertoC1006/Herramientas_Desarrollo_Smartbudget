import 'package:flutter_riverpod/flutter_riverpod.dart';

class PrivacySettings {
  final bool hideAmounts;
  final bool appLockEnabled;
  final bool isLocked;

  const PrivacySettings({
    this.hideAmounts = false,
    this.appLockEnabled = false,
    this.isLocked = false,
  });

  PrivacySettings copyWith({
    bool? hideAmounts,
    bool? appLockEnabled,
    bool? isLocked,
  }) {
    return PrivacySettings(
      hideAmounts: hideAmounts ?? this.hideAmounts,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}

class PrivacySettingsNotifier extends Notifier<PrivacySettings> {
  @override
  PrivacySettings build() => const PrivacySettings();

  void setHideAmounts(bool value) {
    state = state.copyWith(hideAmounts: value);
  }

  void setAppLockEnabled(bool value) {
    state = state.copyWith(appLockEnabled: value, isLocked: value);
  }

  void lockIfEnabled() {
    if (!state.appLockEnabled || state.isLocked) return;
    state = state.copyWith(isLocked: true);
  }

  void unlock() {
    state = state.copyWith(isLocked: false);
  }
}

final privacySettingsProvider =
    NotifierProvider<PrivacySettingsNotifier, PrivacySettings>(
      PrivacySettingsNotifier.new,
    );

String privacyAmount(
  double value, {
  required bool hidden,
  bool negative = false,
  bool positive = false,
}) {
  final sign = negative
      ? '-'
      : positive
      ? '+ '
      : '';

  if (hidden) return '${sign}S/ ••••';
  return '${sign}S/ ${value.toStringAsFixed(2)}';
}
