import 'package:flutter/material.dart';

import '../auth/models/app_user.dart';
import 'models/onboarding_options.dart';

/// Sample values used by the onboarding flow until the backend exists.
abstract final class OnboardingDemoData {
  /// Time zones offered per country.
  static const Map<Country, List<String>> timeZones = {
    Country.india: ['Asia/Kolkata (IST, UTC+5:30)'],
    Country.unitedStates: [
      'America/New_York (ET)',
      'America/Chicago (CT)',
      'America/Denver (MT)',
      'America/Los_Angeles (PT)',
    ],
  };

  /// Lead-source toggles per country.
  static const Map<Country, List<String>> leadSources = {
    Country.india: [
      'Website form',
      'Facebook Lead Ads',
      '99acres',
      'MagicBricks',
      'Housing.com',
    ],
    Country.unitedStates: [
      'Website form',
      'Facebook Lead Ads',
      'Zillow',
      'Realtor.com',
    ],
  };

  /// Sample webhook URL shown on the CRM step.
  static const String webhookUrl =
      'https://hooks.mergro.ai/v1/leads/skyline-7f3a9c';

  /// Sample numbers offered when buying a new line.
  static const Map<Country, List<String>> sampleNumbers = {
    Country.india: ['+91 80 4718 2290', '+91 22 6914 3305', '+91 11 4102 7781'],
    Country.unitedStates: [
      '+1 (512) 555-0142',
      '+1 (737) 555-0178',
      '+1 (415) 555-0119',
    ],
  };

  /// Allowed AI calling window per country.
  static const Map<Country, (TimeOfDay, TimeOfDay)> callingWindows = {
    Country.india: (
      TimeOfDay(hour: 9, minute: 0),
      TimeOfDay(hour: 21, minute: 0),
    ),
    Country.unitedStates: (
      TimeOfDay(hour: 8, minute: 0),
      TimeOfDay(hour: 21, minute: 0),
    ),
  };

  /// Compliance banner per country.
  static const Map<Country, String> complianceNotes = {
    Country.india:
        'TRAI DND: numbers on the National Do Not Call registry are skipped '
        'unless the lead gave explicit consent, and calls stay within the '
        'calling window.',
    Country.unitedStates:
        'TCPA: AI calls need prior express consent, must respect the '
        'calling window in the lead\'s local time, and honour opt-outs.',
  };

  /// Default AI agent name.
  static const String defaultAgentName = 'Maya';

  /// Brokerage name used in the greeting when step 1 is empty.
  static const String fallbackBrokerageName = 'your brokerage';

  /// Builds the greeting preview for [agentName] and [brokerageName].
  static String greeting(String agentName, String brokerageName) =>
      'Hi, this is $agentName, an AI assistant calling from $brokerageName '
      'about your property enquiry. Is now a good time to talk?';

  /// Languages the AI agent can speak.
  static const List<String> agentLanguages = ['English', 'Hindi', 'Hinglish'];

  /// Languages a sales agent can list on their profile.
  static const List<String> spokenLanguages = [
    'English',
    'Hindi',
    'Marathi',
    'Tamil',
    'Telugu',
    'Kannada',
    'Bengali',
    'Spanish',
  ];

  /// Roles an admin can assign to invitees.
  static const List<UserRole> inviteRoles = [
    UserRole.salesAgent,
    UserRole.teamLead,
    UserRole.operations,
    UserRole.complianceReviewer,
  ];

  /// Short weekday labels, Monday first (index + 1 = [DateTime.weekday]).
  static const List<String> weekdayLabels = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  /// Default working / viewing days (Mon–Sat).
  static const Set<int> defaultDays = {1, 2, 3, 4, 5, 6};

  /// Viewing length options in minutes.
  static const List<int> viewingLengths = [30, 45, 60];

  /// Buffer options between viewings in minutes.
  static const List<int> bufferOptions = [0, 15, 30];
}
