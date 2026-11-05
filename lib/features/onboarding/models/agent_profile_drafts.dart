import 'package:flutter/material.dart';

import '../../../core/validation/form_validators.dart';

/// Draft for agent step 1: personal profile.
@immutable
class AgentProfileDraft {
  /// Creates a draft.
  const AgentProfileDraft({
    this.fullName = '',
    this.mobileNumber = '',
    this.hasPhoto = false,
    this.languages = const {'English'},
  });

  /// Full name (required).
  final String fullName;

  /// Mobile number (required).
  final String mobileNumber;

  /// Whether the placeholder photo was "uploaded".
  final bool hasPhoto;

  /// Languages the agent speaks.
  final Set<String> languages;

  /// Up to two initials from [fullName], for the avatar.
  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
  }

  /// Mobile error to show inline; null while empty or valid.
  String? get mobileError =>
      mobileNumber.trim().isEmpty ? null : FormValidators.phone(mobileNumber);

  /// Name and a valid mobile number are set.
  bool get isValid =>
      fullName.trim().isNotEmpty && FormValidators.phone(mobileNumber) == null;

  /// Copies with changes.
  AgentProfileDraft copyWith({
    String? fullName,
    String? mobileNumber,
    bool? hasPhoto,
    Set<String>? languages,
  }) {
    return AgentProfileDraft(
      fullName: fullName ?? this.fullName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      hasPhoto: hasPhoto ?? this.hasPhoto,
      languages: languages ?? this.languages,
    );
  }
}

/// Draft for agent step 2: hot-lead alerts.
@immutable
class HotLeadAlertsDraft {
  /// Creates a draft with every alert on and 21:00–08:00 quiet hours.
  const HotLeadAlertsDraft({
    this.pushEnabled = true,
    this.smsFallbackEnabled = true,
    this.soundEnabled = true,
    this.quietStart = const TimeOfDay(hour: 21, minute: 0),
    this.quietEnd = const TimeOfDay(hour: 8, minute: 0),
  });

  /// Push notifications.
  final bool pushEnabled;

  /// SMS when push isn't acknowledged.
  final bool smsFallbackEnabled;

  /// Alert sound.
  final bool soundEnabled;

  /// Quiet hours start (may be after [quietEnd]; it spans midnight).
  final TimeOfDay quietStart;

  /// Quiet hours end.
  final TimeOfDay quietEnd;

  /// At least one alert channel (push or SMS) must stay on.
  bool get isValid => pushEnabled || smsFallbackEnabled;

  /// Copies with changes.
  HotLeadAlertsDraft copyWith({
    bool? pushEnabled,
    bool? smsFallbackEnabled,
    bool? soundEnabled,
    TimeOfDay? quietStart,
    TimeOfDay? quietEnd,
  }) {
    return HotLeadAlertsDraft(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      smsFallbackEnabled: smsFallbackEnabled ?? this.smsFallbackEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      quietStart: quietStart ?? this.quietStart,
      quietEnd: quietEnd ?? this.quietEnd,
    );
  }
}
