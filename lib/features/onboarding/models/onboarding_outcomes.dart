import '../../../core/network/api_exception.dart';
import '../../auth/models/app_user.dart';

/// Result of loading, saving or skipping an onboarding step, or sending
/// invites. The screen reacts; controllers never navigate.
sealed class StepActionOutcome {
  /// Base constructor.
  const StepActionOutcome();
}

/// The action succeeded.
class StepActionSucceeded extends StepActionOutcome {
  /// Creates a success outcome.
  const StepActionSucceeded();
}

/// The action failed; [message] is user-facing.
class StepActionFailed extends StepActionOutcome {
  /// Creates a failure outcome.
  const StepActionFailed(this.message, {this.isSessionExpired = false});

  /// Builds the failure for an API error.
  factory StepActionFailed.from(ApiException error) => StepActionFailed(
    error.message,
    isSessionExpired: error.kind == ApiErrorKind.unauthorized,
  );

  /// Why it failed.
  final String message;

  /// True when the user must sign in again.
  final bool isSessionExpired;
}

/// Result of finishing onboarding.
sealed class OnboardingFinishOutcome {
  /// Base constructor.
  const OnboardingFinishOutcome();
}

/// Onboarding was saved; show the success screen.
class OnboardingFinished extends OnboardingFinishOutcome {
  /// Creates a success outcome for [role].
  const OnboardingFinished(this.role);

  /// Role that finished, to pick the success copy.
  final UserRole role;
}

/// Finishing failed or was already running; [message] is user-facing.
class OnboardingFinishFailed extends OnboardingFinishOutcome {
  /// Creates a failure outcome.
  const OnboardingFinishFailed(this.message, {this.isSessionExpired = false});

  /// Why it failed.
  final String message;

  /// True when the user must sign in again.
  final bool isSessionExpired;
}
