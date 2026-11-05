import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../auth/controllers/current_user_controller.dart';
import '../../auth/models/app_user.dart';
import '../models/onboarding_flow_models.dart';
import '../repositories/onboarding_repository.dart';
import 'onboarding_step_data.dart';

/// Position in the onboarding flow. Kept alive (not auto-disposed) so it
/// survives step changes; cleared by `resetOnboarding`.
final onboardingFlowControllerProvider =
    NotifierProvider<OnboardingFlowController, OnboardingFlowState>(
      OnboardingFlowController.new,
    );

/// Moves through the role's steps (load, next, back, skip, finish) and
/// saves each one on the server.
class OnboardingFlowController extends Notifier<OnboardingFlowState> {
  /// Message returned when another server call is already running.
  static const String busyMessage = 'Saving…';

  /// Builds the step list for the signed-in user's role, in the loading
  /// state: the screen calls [loadProgress] to resume saved progress.
  @override
  OnboardingFlowState build() {
    final role = ref.watch(currentUserProvider)?.role ?? UserRole.salesAgent;
    return OnboardingFlowState(
      role: role,
      steps: OnboardingStepId.stepsFor(role),
      isLoading: true,
    );
  }

  OnboardingRepository get _repository =>
      ref.read(onboardingRepositoryProvider);

  /// Loads saved progress: restores each saved draft and opens the first
  /// step that is neither completed nor skipped (Review when all are).
  Future<StepActionOutcome> loadProgress() async {
    if (state.isBusy && !state.isLoading) {
      return const StepActionFailed(busyMessage);
    }
    state = state.copyWith(isLoading: true, loadError: () => null);
    try {
      final progress = await _repository.fetchProgress();
      if (!ref.mounted) return const StepActionFailed(busyMessage);
      progress.drafts.forEach((step, json) => restoreStep(ref, step, json));
      final done = {...progress.completedSteps, ...progress.skippedSteps};
      final firstOpen = state.steps.indexWhere((step) => !done.contains(step));
      state = state.copyWith(
        isLoading: false,
        completedSteps: progress.completedSteps,
        skippedSteps: progress.skippedSteps,
        currentIndex: firstOpen == -1 ? _lastIndex : firstOpen,
      );
      return const StepActionSucceeded();
    } on ApiException catch (error) {
      if (!ref.mounted) return const StepActionFailed(busyMessage);
      state = state.copyWith(isLoading: false, loadError: () => error.message);
      return StepActionFailed.from(error);
    }
  }

  /// Saves the current step, marks it done and advances (to Review after
  /// the last admin step). On the last step of a flow without Review it
  /// stays put; the screen then calls [finish].
  Future<StepActionOutcome> next() async {
    final step = state.currentStep;
    if (step == null || state.isBusy) {
      return const StepActionFailed(busyMessage);
    }
    return _saveThenAdvance(
      () => _repository.saveStep(step, stepPayload(ref, step)),
      () => state.copyWith(
        completedSteps: {...state.completedSteps, step},
        skippedSteps: {...state.skippedSteps}..remove(step),
      ),
    );
  }

  /// Skips the current step if it is optional, then advances.
  Future<StepActionOutcome> skip() async {
    final step = state.currentStep;
    if (step == null || !step.isOptional || state.isBusy) {
      return const StepActionFailed(busyMessage);
    }
    return _saveThenAdvance(
      () => _repository.skipStep(step),
      () => state.copyWith(
        skippedSteps: {...state.skippedSteps, step},
        completedSteps: {...state.completedSteps}..remove(step),
      ),
    );
  }

  /// Goes back one step (from Review, back to the last step).
  void back() {
    if (state.currentIndex == 0 || state.isBusy) return;
    state = state.copyWith(currentIndex: state.currentIndex - 1);
  }

  /// Marks onboarding complete on the server.
  Future<OnboardingFinishOutcome> finish() async {
    if (state.isBusy) return const OnboardingFinishFailed(busyMessage);
    state = state.copyWith(isFinishing: true);
    try {
      await _repository.complete();
    } on ApiException catch (error) {
      if (!ref.mounted) return const OnboardingFinishFailed(busyMessage);
      state = state.copyWith(isFinishing: false);
      return OnboardingFinishFailed(
        error.message,
        isSessionExpired: error.kind == ApiErrorKind.unauthorized,
      );
    }
    if (!ref.mounted) return const OnboardingFinishFailed(busyMessage);
    state = state.copyWith(isFinishing: false);
    return OnboardingFinished(state.role);
  }

  /// Runs [save]; on success applies [record] and moves to the next index.
  Future<StepActionOutcome> _saveThenAdvance(
    Future<void> Function() save,
    OnboardingFlowState Function() record,
  ) async {
    state = state.copyWith(isSaving: true);
    try {
      await save();
    } on ApiException catch (error) {
      if (!ref.mounted) return const StepActionFailed(busyMessage);
      state = state.copyWith(isSaving: false);
      return StepActionFailed.from(error);
    }
    if (!ref.mounted) return const StepActionFailed(busyMessage);
    state = record().copyWith(isSaving: false, currentIndex: _nextIndex());
    return const StepActionSucceeded();
  }

  /// Last reachable index: Review for admins, else the last step.
  int get _lastIndex =>
      state.hasReview ? state.steps.length : state.steps.length - 1;

  /// Index after the current one, capped at [_lastIndex].
  int _nextIndex() => (state.currentIndex + 1).clamp(0, _lastIndex);
}
