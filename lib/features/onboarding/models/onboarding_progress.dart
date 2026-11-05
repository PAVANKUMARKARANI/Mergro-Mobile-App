import 'package:flutter/foundation.dart';

import '../../../core/network/api_response_mapper.dart';
import 'onboarding_flow_models.dart';

/// Saved onboarding progress from `GET /api/onboarding`.
@immutable
class OnboardingProgress {
  /// Creates progress.
  const OnboardingProgress({
    this.completedSteps = const {},
    this.skippedSteps = const {},
    this.drafts = const {},
    this.isComplete = false,
  });

  /// Parses the response's `details`; unknown step names are ignored.
  factory OnboardingProgress.fromJson(JsonMap json) {
    final rawDrafts = json['drafts'];
    final drafts = <OnboardingStepId, JsonMap>{};
    if (rawDrafts is Map) {
      for (final entry in rawDrafts.entries) {
        final step = _stepNamed(entry.key);
        final draft = entry.value;
        if (step != null && draft is Map<String, dynamic>) drafts[step] = draft;
      }
    }
    return OnboardingProgress(
      completedSteps: _steps(json['completedSteps']),
      skippedSteps: _steps(json['skippedSteps']),
      drafts: drafts,
      isComplete: json['onboardingCompleted'] == true,
    );
  }

  /// Steps saved with Continue.
  final Set<OnboardingStepId> completedSteps;

  /// Optional steps skipped.
  final Set<OnboardingStepId> skippedSteps;

  /// Last saved data per step, in the wire format of `draft_json.dart`.
  final Map<OnboardingStepId, JsonMap> drafts;

  /// True once onboarding was completed.
  final bool isComplete;

  /// Step called [name], or null.
  static OnboardingStepId? _stepNamed(Object? name) {
    for (final step in OnboardingStepId.values) {
      if (step.name == name) return step;
    }
    return null;
  }

  /// Known steps named in [json] (a list of names).
  static Set<OnboardingStepId> _steps(Object? json) {
    if (json is! List) return const {};
    return json.map(_stepNamed).whereType<OnboardingStepId>().toSet();
  }
}

/// Outcome of `POST /api/team/invites`.
@immutable
class InviteResult {
  /// Creates a result.
  const InviteResult({required this.sentEmails, required this.failures});

  /// Parses the response's `details.results`.
  factory InviteResult.fromJson(JsonMap json) {
    final sent = <String>{};
    final failures = <String, String>{};
    final results = json['results'];
    if (results is List) {
      for (final row in results.whereType<Map<String, dynamic>>()) {
        final email = row['email'];
        if (email is! String) continue;
        if (row['status'] == 'invited') {
          sent.add(email);
        } else {
          failures[email] = row['reason'] as String? ?? 'Could not invite.';
        }
      }
    }
    return InviteResult(sentEmails: sent, failures: failures);
  }

  /// Emails that were invited.
  final Set<String> sentEmails;

  /// Emails that failed, with the server's reason.
  final Map<String, String> failures;
}
