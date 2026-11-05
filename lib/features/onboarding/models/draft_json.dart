import 'package:flutter/material.dart';

import '../../../core/network/api_response_mapper.dart';
import '../../../core/utils/time_of_day_format.dart';
import '../../../shared/widgets/integration_card.dart';
import 'agent_profile_drafts.dart';
import 'agent_setup_drafts.dart';
import 'onboarding_options.dart';
import 'phone_line_draft.dart';
import 'setup_drafts.dart';

// Wire format of `PUT /api/onboarding/steps/{step}` → `data`, and of the
// `drafts` returned by `GET /api/onboarding`. Enums travel by name and times
// as "HH:mm"; the backend validates the same shapes (onboardingSteps.js).
// Each `fromJson` falls back to the draft's defaults for missing fields.

/// Enum value called [name] in [values], or null.
T? _byName<T extends Enum>(List<T> values, Object? name) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  return null;
}

/// Non-empty list of strings from [json], or null.
Set<String>? _stringSet(Object? json) {
  if (json is! List) return null;
  final strings = json.whereType<String>().toSet();
  return strings.isEmpty ? null : strings;
}

/// JSON for admin step 1.
extension BrokerageProfileJson on BrokerageProfileDraft {
  /// Converts to the API shape (the logo is not uploaded yet).
  JsonMap toJson() => {
    'brokerageName': brokerageName.trim(),
    'country': country?.name,
    'timeZone': timeZone,
    'officeAddress': officeAddress.trim(),
    'opensAt': opensAt.label24,
    'closesAt': closesAt.label24,
  };

  /// Restores a saved draft.
  static BrokerageProfileDraft fromJson(JsonMap json) {
    const defaults = BrokerageProfileDraft();
    return BrokerageProfileDraft(
      brokerageName: json['brokerageName'] as String? ?? '',
      country: _byName(Country.values, json['country']),
      timeZone: json['timeZone'] as String?,
      officeAddress: json['officeAddress'] as String? ?? '',
      opensAt: parseTimeOfDay24(json['opensAt']) ?? defaults.opensAt,
      closesAt: parseTimeOfDay24(json['closesAt']) ?? defaults.closesAt,
    );
  }
}

/// JSON for admin step 2.
extension CrmJson on CrmDraft {
  /// Converts to the API shape. Zoho's connection is not sent: the OAuth
  /// flow is still simulated in the app.
  JsonMap toJson() => {'enabledLeadSources': enabledLeadSources.toList()};

  /// Restores a saved draft. The step could only be saved with Zoho
  /// connected, so it is restored as connected.
  static CrmDraft fromJson(JsonMap json) => CrmDraft(
    zohoStatus: IntegrationStatus.connected,
    enabledLeadSources: _stringSet(json['enabledLeadSources']) ?? const {},
  );
}

/// JSON for the viewing (admin) and personal (agent) calendar steps.
extension CalendarJson on CalendarDraft {
  /// Converts to the API shape (days are 1 = Monday … 7 = Sunday).
  JsonMap toJson() => {
    'viewingMinutes': viewingMinutes,
    'bufferMinutes': bufferMinutes,
    'days': days.toList()..sort(),
    'startTime': startTime.label24,
    'endTime': endTime.label24,
  };

  /// Restores a saved draft; calendar connections are not restored.
  static CalendarDraft fromJson(JsonMap json) {
    const defaults = CalendarDraft();
    final days = json['days'];
    return CalendarDraft(
      viewingMinutes: json['viewingMinutes'] as int? ?? defaults.viewingMinutes,
      bufferMinutes: json['bufferMinutes'] as int? ?? defaults.bufferMinutes,
      days: days is List ? days.whereType<int>().toSet() : defaults.days,
      startTime: parseTimeOfDay24(json['startTime']) ?? defaults.startTime,
      endTime: parseTimeOfDay24(json['endTime']) ?? defaults.endTime,
    );
  }
}

/// JSON for admin step 4.
extension PhoneLineJson on PhoneLineDraft {
  /// Converts to the API shape; [number] is the chosen or verified number.
  JsonMap toJson() => {
    'provider': provider?.name,
    'numberSource': numberSource.name,
    'number': switch (numberSource) {
      NumberSource.newNumber => selectedNumber,
      NumberSource.existing => existingNumber.trim(),
    },
    'consentConfirmed': consentConfirmed,
  };

  /// Restores a saved draft. An existing number could only be saved once
  /// verified, so it is restored as verified.
  static PhoneLineDraft fromJson(JsonMap json) {
    final source =
        _byName(NumberSource.values, json['numberSource']) ??
        NumberSource.newNumber;
    final number = json['number'] as String?;
    return PhoneLineDraft(
      provider: _byName(TelephonyProvider.values, json['provider']),
      numberSource: source,
      selectedNumber: source == NumberSource.newNumber ? number : null,
      existingNumber: source == NumberSource.existing ? number ?? '' : '',
      isVerified: source == NumberSource.existing && number != null,
      consentConfirmed: json['consentConfirmed'] == true,
    );
  }
}

/// JSON for admin step 5.
extension AiAgentJson on AiAgentDraft {
  /// Converts to the API shape (the AI always discloses itself; the server
  /// enforces that too).
  JsonMap toJson() => {
    'agentName': agentName.trim(),
    'voice': voice.name,
    'languages': languages.toList(),
  };

  /// Restores a saved draft.
  static AiAgentDraft fromJson(JsonMap json) {
    const defaults = AiAgentDraft();
    return AiAgentDraft(
      agentName: json['agentName'] as String? ?? defaults.agentName,
      voice: _byName(AgentVoice.values, json['voice']) ?? defaults.voice,
      languages: _stringSet(json['languages']) ?? defaults.languages,
    );
  }
}

/// JSON for the agent / team-lead profile step.
extension AgentProfileJson on AgentProfileDraft {
  /// Converts to the API shape (the photo is not uploaded yet).
  JsonMap toJson() => {
    'fullName': fullName.trim(),
    'mobileNumber': mobileNumber.trim(),
    'languages': languages.toList(),
  };

  /// Restores a saved draft.
  static AgentProfileDraft fromJson(JsonMap json) => AgentProfileDraft(
    fullName: json['fullName'] as String? ?? '',
    mobileNumber: json['mobileNumber'] as String? ?? '',
    languages: _stringSet(json['languages']) ?? const {'English'},
  );
}

/// JSON for the hot-lead alerts step.
extension HotLeadAlertsJson on HotLeadAlertsDraft {
  /// Converts to the API shape.
  JsonMap toJson() => {
    'pushEnabled': pushEnabled,
    'smsFallbackEnabled': smsFallbackEnabled,
    'soundEnabled': soundEnabled,
    'quietStart': quietStart.label24,
    'quietEnd': quietEnd.label24,
  };

  /// Restores a saved draft.
  static HotLeadAlertsDraft fromJson(JsonMap json) {
    const defaults = HotLeadAlertsDraft();
    TimeOfDay timeOr(String key, TimeOfDay fallback) =>
        parseTimeOfDay24(json[key]) ?? fallback;
    return HotLeadAlertsDraft(
      pushEnabled: json['pushEnabled'] as bool? ?? defaults.pushEnabled,
      smsFallbackEnabled:
          json['smsFallbackEnabled'] as bool? ?? defaults.smsFallbackEnabled,
      soundEnabled: json['soundEnabled'] as bool? ?? defaults.soundEnabled,
      quietStart: timeOr('quietStart', defaults.quietStart),
      quietEnd: timeOr('quietEnd', defaults.quietEnd),
    );
  }
}
