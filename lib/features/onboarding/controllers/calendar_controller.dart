import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_durations.dart';
import '../../../core/utils/set_toggle.dart';
import '../../../shared/widgets/integration_card.dart';
import '../models/onboarding_options.dart';
import '../models/setup_drafts.dart';

/// Admin step 3 draft (brokerage viewing calendar).
final viewingCalendarControllerProvider =
    NotifierProvider<CalendarController, CalendarDraft>(CalendarController.new);

/// Agent step 3 draft (personal availability). Same logic, separate draft.
final agentCalendarControllerProvider =
    NotifierProvider<CalendarController, CalendarDraft>(CalendarController.new);

/// Connects calendars and edits bookable days and hours.
class CalendarController extends Notifier<CalendarDraft> {
  /// Starts with Mon–Sat, 10:00–19:00 and nothing connected.
  @override
  CalendarDraft build() => const CalendarDraft();

  /// Connects [provider]: Not connected → Connecting… → Connected.
  Future<void> connect(CalendarProvider provider) async {
    if (state.statusOf(provider) != IntegrationStatus.notConnected) return;
    _setStatus(provider, IntegrationStatus.connecting);

    // TODO(backend): calendar OAuth — GET /integrations/{google|outlook}-
    // calendar/authorize-url, then POST .../callback {code} to store tokens.
    await Future<void>.delayed(AppDurations.simulatedNetwork);
    if (!ref.mounted) return;

    _setStatus(provider, IntegrationStatus.connected);
  }

  /// Disconnects [provider].
  void disconnect(CalendarProvider provider) {
    // TODO(backend): DELETE /integrations/{google|outlook}-calendar.
    _setStatus(provider, IntegrationStatus.notConnected);
  }

  /// Sets the viewing length in minutes.
  void setViewingMinutes(int minutes) =>
      state = state.copyWith(viewingMinutes: minutes);

  /// Sets the buffer between viewings in minutes.
  void setBufferMinutes(int minutes) =>
      state = state.copyWith(bufferMinutes: minutes);

  /// Toggles a weekday (1 = Monday … 7 = Sunday).
  void toggleDay(int weekday) =>
      state = state.copyWith(days: state.days.toggled(weekday));

  /// Sets the start of bookable hours.
  void setStartTime(TimeOfDay time) => state = state.copyWith(startTime: time);

  /// Sets the end of bookable hours.
  void setEndTime(TimeOfDay time) => state = state.copyWith(endTime: time);

  /// Writes one provider's status.
  void _setStatus(CalendarProvider provider, IntegrationStatus status) {
    state = state.copyWith(statuses: {...state.statuses, provider: status});
  }
}
