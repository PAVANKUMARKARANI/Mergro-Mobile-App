import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/ui.dart';
import '../../auth/models/app_user.dart';
import '../controllers/invite_team_controller.dart';
import '../controllers/onboarding_flow_controller.dart';
import '../controllers/onboarding_providers.dart';
import '../models/onboarding_flow_models.dart';
import '../widgets/review_view.dart';
import '../widgets/step_content.dart';
import '../widgets/step_rail.dart';

/// Role-based onboarding: progress header, sliding step content and the
/// Back / Continue / Skip bar. Shows a step rail at ≥ 900 px.
class OnboardingScreen extends ConsumerStatefulWidget {
  /// Creates the screen with its navigation callback.
  const OnboardingScreen({super.key, required this.onFinished});

  /// Called with the role once onboarding is saved.
  final ValueChanged<UserRole> onFinished;

  /// Creates the state tracking the slide direction.
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

/// Tracks the last step index so transitions slide the right way.
class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _lastIndex = 0;
  int _direction = 1;

  OnboardingFlowController get _flow =>
      ref.read(onboardingFlowControllerProvider.notifier);

  /// Runs the step's Continue action, then advances or finishes.
  Future<void> _continue() async {
    FocusScope.of(context).unfocus();
    final flow = ref.read(onboardingFlowControllerProvider);
    if (flow.currentStep == OnboardingStepId.inviteTeam) {
      final isSent = await ref
          .read(inviteTeamControllerProvider.notifier)
          .sendInvites();
      if (!isSent || !mounted) return;
    }
    if (flow.isReview || (flow.isLastStep && !flow.hasReview)) {
      await _finish();
    } else {
      _flow.next();
    }
  }

  /// Skips the optional step; skipping the last agent step finishes.
  Future<void> _skip() async {
    final flow = ref.read(onboardingFlowControllerProvider);
    _flow.skip();
    if (flow.isLastStep && !flow.hasReview) await _finish();
  }

  /// Saves onboarding and hands over to the success screen.
  Future<void> _finish() async {
    final outcome = await _flow.finish();
    if (!mounted) return;
    if (outcome case OnboardingFinished(:final role)) widget.onFinished(role);
  }

  /// Builds the layout for the current step.
  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(onboardingFlowControllerProvider);
    if (flow.currentIndex != _lastIndex) {
      _direction = flow.currentIndex > _lastIndex ? 1 : -1;
      _lastIndex = flow.currentIndex;
    }
    final isWide = MediaQuery.sizeOf(context).width >= AppSizes.wideBreakpoint;
    final content = _buildContent(flow);
    return PopScope(
      // System back steps backwards instead of leaving onboarding.
      canPop: flow.currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _flow.back();
      },
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    StepRail(flow: flow),
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: AppSizes.onboardingContentMaxWidth,
                          ),
                          child: content,
                        ),
                      ),
                    ),
                  ],
                )
              : content,
        ),
        bottomNavigationBar: _buildActionBar(flow),
      ),
    );
  }

  /// Progress header plus the animated step body.
  Widget _buildContent(OnboardingFlowState flow) {
    final step = flow.currentStep;
    final disableMotion = MediaQuery.disableAnimationsOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xs,
            AppSpacing.xs,
            AppSpacing.md,
            0,
          ),
          child: StepProgressHeader(
            currentStep: flow.stepNumber,
            totalSteps: flow.steps.length,
            label: flow.isReview ? 'Review' : null,
            onBack: flow.currentIndex > 0 && !flow.isFinishing
                ? _flow.back
                : null,
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: disableMotion ? Duration.zero : AppDurations.medium,
            transitionBuilder: _slideAndFade,
            child: KeyedSubtree(
              key: ValueKey(flow.currentIndex),
              child: step == null
                  ? ReviewView(flow: flow)
                  : StepContent(step: step),
            ),
          ),
        ),
      ],
    );
  }

  /// Incoming steps slide in from the travel direction; outgoing ones
  /// slide away the opposite way. Both fade.
  Widget _slideAndFade(Widget child, Animation<double> animation) {
    final isIncoming = child.key == ValueKey(_lastIndex);
    final startX =
        AppSizes.stepSlideFraction * _direction * (isIncoming ? 1 : -1);
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(startX, 0),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  /// Back / Continue / Skip bar for the current step.
  Widget _buildActionBar(OnboardingFlowState flow) {
    final step = flow.currentStep;
    final isValid = step == null || ref.watch(stepValidProvider(step));
    final isSendingInvites = ref.watch(
      inviteTeamControllerProvider.select((draft) => draft.isSending),
    );
    final isBusy = flow.isFinishing || isSendingInvites;
    final isFinalStep = flow.isLastStep && !flow.hasReview;
    return BottomActionBar(
      onBack: flow.currentIndex > 0 ? _flow.back : null,
      onSkip: step != null && step.isOptional ? _skip : null,
      continueLabel: flow.isReview
          ? 'Launch Mergro'
          : (isFinalStep ? 'Finish' : 'Continue'),
      isLoading: isBusy,
      // While busy the button shows a spinner and ignores taps itself.
      onContinue: isValid ? _continue : null,
    );
  }
}
