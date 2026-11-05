import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_durations.dart';
import '../../auth/controllers/current_user_controller.dart';
import '../../auth/models/app_user.dart';
import '../models/onboarding_flow_models.dart';

/// Position in the onboarding flow. Kept alive (not auto-disposed) so it
/// survives step changes; cleared by `resetOnboarding`.
final onboardingFlowControllerProvider =
    NotifierProvider<OnboardingFlowController, OnboardingFlowState>(
      OnboardingFlowController.new,
    );

/// Moves through the role's steps: next, back, skip and finish.
class OnboardingFlowController extends Notifier<OnboardingFlowState> {
  /// Message returned when finish is already running.
  static const String busyMessage = 'Finishing setup…';

  /// Builds the step list for the signed-in user's role.
  @override
  OnboardingFlowState build() {
    final role = ref.watch(currentUserProvider)?.role ?? UserRole.salesAgent;
    return OnboardingFlowState(
      role: role,
      steps: OnboardingStepId.stepsFor(role),
    );
  }

  /// Marks the current step done and advances (to Review after the last
  /// admin step). On the last step of a flow without Review, call [finish].
  void next() {
    final step = state.currentStep;
    if (step == null) return;
    // TODO(backend): save step — PUT /onboarding/steps/{step.name} with the
    // step's draft so progress survives app restarts.
    state = state.copyWith(
      completedSteps: {...state.completedSteps, step},
      skippedSteps: {...state.skippedSteps}..remove(step),
      currentIndex: _nextIndex(),
    );
  }

  /// Skips the current step if it is optional, then advances.
  void skip() {
    final step = state.currentStep;
    if (step == null || !step.isOptional) return;
    state = state.copyWith(
      skippedSteps: {...state.skippedSteps, step},
      completedSteps: {...state.completedSteps}..remove(step),
      currentIndex: _nextIndex(),
    );
  }

  /// Goes back one step (from Review, back to the last step).
  void back() {
    if (state.currentIndex == 0 || state.isFinishing) return;
    state = state.copyWith(currentIndex: state.currentIndex - 1);
  }

  /// Saves onboarding as complete.
  Future<OnboardingFinishOutcome> finish() async {
    if (state.isFinishing) return const OnboardingFinishFailed(busyMessage);
    state = state.copyWith(isFinishing: true);

    // TODO(backend): mark onboarding complete — POST /onboarding/complete
    // (for admins this also activates the AI agent and lead webhooks).
    await Future<void>.delayed(AppDurations.simulatedNetwork);
    if (!ref.mounted) return const OnboardingFinishFailed(busyMessage);

    state = state.copyWith(isFinishing: false);
    return OnboardingFinished(state.role);
  }

  /// Index after the current one; stays on the last step when there is no
  /// Review page, and stops at Review when there is.
  int _nextIndex() {
    final lastIndex = state.hasReview
        ? state.steps.length
        : state.steps.length - 1;
    return (state.currentIndex + 1).clamp(0, lastIndex);
  }
}
