import 'package:flutter/material.dart';

import '../../../shared/widgets/integration_card.dart';
import '../onboarding_demo_data.dart';
import 'onboarding_options.dart';

/// Draft for admin step 1: brokerage profile.
@immutable
class BrokerageProfileDraft {
  /// Creates a draft; defaults are an empty profile with 09:00–19:00 hours.
  const BrokerageProfileDraft({
    this.brokerageName = '',
    this.hasLogo = false,
    this.country,
    this.timeZone,
    this.officeAddress = '',
    this.opensAt = const TimeOfDay(hour: 9, minute: 0),
    this.closesAt = const TimeOfDay(hour: 19, minute: 0),
  });

  /// Brokerage name (required).
  final String brokerageName;

  /// Whether the placeholder logo was "uploaded".
  final bool hasLogo;

  /// Country (required).
  final Country? country;

  /// Time zone (required), one of the country's zones.
  final String? timeZone;

  /// Office address (optional).
  final String officeAddress;

  /// Business hours start.
  final TimeOfDay opensAt;

  /// Business hours end.
  final TimeOfDay closesAt;

  /// Name, country and time zone are set, and hours are in order.
  bool get isValid =>
      brokerageName.trim().isNotEmpty &&
      country != null &&
      timeZone != null &&
      opensAt.isBefore(closesAt);

  /// Copies with changes; [timeZone] takes a getter so it can be cleared.
  BrokerageProfileDraft copyWith({
    String? brokerageName,
    bool? hasLogo,
    Country? country,
    ValueGetter<String?>? timeZone,
    String? officeAddress,
    TimeOfDay? opensAt,
    TimeOfDay? closesAt,
  }) {
    return BrokerageProfileDraft(
      brokerageName: brokerageName ?? this.brokerageName,
      hasLogo: hasLogo ?? this.hasLogo,
      country: country ?? this.country,
      timeZone: timeZone != null ? timeZone() : this.timeZone,
      officeAddress: officeAddress ?? this.officeAddress,
      opensAt: opensAt ?? this.opensAt,
      closesAt: closesAt ?? this.closesAt,
    );
  }
}

/// Draft for admin step 2: CRM connection and lead sources.
@immutable
class CrmDraft {
  /// Creates a draft; Zoho starts disconnected with no sources enabled.
  const CrmDraft({
    this.zohoStatus = IntegrationStatus.notConnected,
    this.enabledLeadSources = const {},
  });

  /// Zoho CRM connection state (required to continue).
  final IntegrationStatus zohoStatus;

  /// Names of enabled lead sources.
  final Set<String> enabledLeadSources;

  /// Zoho CRM must be connected.
  bool get isValid => zohoStatus == IntegrationStatus.connected;

  /// Copies with changes.
  CrmDraft copyWith({
    IntegrationStatus? zohoStatus,
    Set<String>? enabledLeadSources,
  }) {
    return CrmDraft(
      zohoStatus: zohoStatus ?? this.zohoStatus,
      enabledLeadSources: enabledLeadSources ?? this.enabledLeadSources,
    );
  }
}

/// Draft for calendar steps (admin viewings and agent availability).
@immutable
class CalendarDraft {
  /// Creates a draft with Mon–Sat, 10:00–19:00, 30 min viewings.
  const CalendarDraft({
    this.statuses = const {},
    this.viewingMinutes = 30,
    this.bufferMinutes = 15,
    this.days = OnboardingDemoData.defaultDays,
    this.startTime = const TimeOfDay(hour: 10, minute: 0),
    this.endTime = const TimeOfDay(hour: 19, minute: 0),
  });

  /// Connection state per calendar provider (missing = not connected).
  final Map<CalendarProvider, IntegrationStatus> statuses;

  /// Viewing length in minutes (admin only).
  final int viewingMinutes;

  /// Buffer between viewings in minutes (admin only).
  final int bufferMinutes;

  /// Selected weekdays (1 = Monday … 7 = Sunday).
  final Set<int> days;

  /// Start of bookable hours.
  final TimeOfDay startTime;

  /// End of bookable hours.
  final TimeOfDay endTime;

  /// Status for [provider], defaulting to not connected.
  IntegrationStatus statusOf(CalendarProvider provider) =>
      statuses[provider] ?? IntegrationStatus.notConnected;

  /// At least one day is selected and the hours are in order.
  bool get isValid => days.isNotEmpty && startTime.isBefore(endTime);

  /// Copies with changes.
  CalendarDraft copyWith({
    Map<CalendarProvider, IntegrationStatus>? statuses,
    int? viewingMinutes,
    int? bufferMinutes,
    Set<int>? days,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
  }) {
    return CalendarDraft(
      statuses: statuses ?? this.statuses,
      viewingMinutes: viewingMinutes ?? this.viewingMinutes,
      bufferMinutes: bufferMinutes ?? this.bufferMinutes,
      days: days ?? this.days,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}
