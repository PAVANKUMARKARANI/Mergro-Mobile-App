import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/onboarding_options.dart';
import '../models/setup_drafts.dart';
import '../onboarding_demo_data.dart';

/// Admin step 1 draft; kept alive so values survive Back / Next.
final brokerageProfileControllerProvider =
    NotifierProvider<BrokerageProfileController, BrokerageProfileDraft>(
      BrokerageProfileController.new,
    );

/// Edits the brokerage profile draft.
class BrokerageProfileController extends Notifier<BrokerageProfileDraft> {
  /// Starts with an empty profile.
  @override
  BrokerageProfileDraft build() => const BrokerageProfileDraft();

  /// Updates the brokerage name.
  void updateName(String name) => state = state.copyWith(brokerageName: name);

  /// Shows or removes the placeholder logo (no file picker in this phase).
  void setHasLogo(bool hasLogo) => state = state.copyWith(hasLogo: hasLogo);

  /// Sets the country, auto-picking the time zone when only one exists and
  /// clearing a zone that doesn't belong to the new country.
  void setCountry(Country country) {
    final zones = OnboardingDemoData.timeZones[country] ?? const [];
    final keepsZone = zones.contains(state.timeZone);
    final String? zone = keepsZone
        ? state.timeZone
        : (zones.length == 1 ? zones.first : null);
    state = state.copyWith(country: country, timeZone: () => zone);
  }

  /// Sets the time zone.
  void setTimeZone(String timeZone) =>
      state = state.copyWith(timeZone: () => timeZone);

  /// Updates the office address.
  void updateAddress(String address) =>
      state = state.copyWith(officeAddress: address);

  /// Sets the opening time.
  void setOpensAt(TimeOfDay time) => state = state.copyWith(opensAt: time);

  /// Sets the closing time.
  void setClosesAt(TimeOfDay time) => state = state.copyWith(closesAt: time);
}
