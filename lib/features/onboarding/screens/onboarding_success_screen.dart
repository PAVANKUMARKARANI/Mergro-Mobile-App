import 'dart:async';

import '../../../shared/ui.dart';
import '../../auth/models/app_user.dart';
import '../widgets/success_check_painter.dart';

/// Celebration after onboarding: a self-drawing teal check with rippling
/// call rings and a message. Moves on by itself [AppDurations.successHold]
/// after the animation ends; there is no button.
class OnboardingSuccessScreen extends StatefulWidget {
  /// Creates the screen.
  const OnboardingSuccessScreen({
    super.key,
    required this.title,
    required this.message,
    required this.onContinue,
  });

  /// Success copy for [role]: admins launch Mergro, staff are "all set".
  factory OnboardingSuccessScreen.forRole({
    Key? key,
    required UserRole role,
    required VoidCallback onContinue,
  }) {
    final isAdmin = role == UserRole.brokerageAdmin;
    return OnboardingSuccessScreen(
      key: key,
      onContinue: onContinue,
      title: isAdmin ? 'Mergro is live' : "You're all set",
      message: isAdmin
          ? 'Your AI agent will now call every new lead within 60 seconds.'
          : "We'll alert you the moment the AI qualifies a hot lead.",
    );
  }

  /// Headline, e.g. "Mergro is live".
  final String title;

  /// Supporting text.
  final String message;

  /// Leaves the success screen (opens the dashboard); called exactly once.
  final VoidCallback onContinue;

  /// Creates the state owning the animation controller.
  @override
  State<OnboardingSuccessScreen> createState() =>
      _OnboardingSuccessScreenState();
}

/// Owns the celebration animation.
class _OnboardingSuccessScreenState extends State<OnboardingSuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.successCelebration,
  );
  late final Animation<double> _circle = _interval(0, 0.3, Curves.easeOutBack);
  late final Animation<double> _check = _interval(0.25, 0.6, Curves.easeOut);
  late final Animation<double> _firstRing = _interval(0.3, 0.9, Curves.easeOut);
  late final Animation<double> _secondRing = _interval(0.45, 1, Curves.easeOut);
  bool _hasStarted = false;
  bool _hasContinued = false;
  Timer? _holdTimer;

  /// Builds a curved sub-animation of the controller.
  Animation<double> _interval(double begin, double end, Curve curve) =>
      CurvedAnimation(
        parent: _controller,
        curve: Interval(begin, end, curve: curve),
      );

  /// Starts the animation, or jumps to the end with reduced motion.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasStarted) return;
    _hasStarted = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
      _startHold();
    } else {
      _controller.forward().whenComplete(_startHold);
    }
  }

  /// Waits [AppDurations.successHold], then continues to the dashboard.
  void _startHold() {
    if (!mounted || _holdTimer != null) return;
    _holdTimer = Timer(AppDurations.successHold, _continue);
  }

  /// Calls [OnboardingSuccessScreen.onContinue] once.
  void _continue() {
    if (!mounted || _hasContinued) return;
    _hasContinued = true;
    widget.onContinue();
  }

  /// Cancels the pending move and releases the controller.
  @override
  void dispose() {
    _holdTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Builds the screen.
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = context.textStyles;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSizes.contentMaxWidth,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.xxxl),
                  Center(child: _buildCelebration(palette)),
                  const SizedBox(height: AppSpacing.xxxl + AppSpacing.xl),
                  Semantics(
                    header: true,
                    liveRegion: true,
                    child: Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: text.displaySmall,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    widget.message,
                    textAlign: TextAlign.center,
                    style: text.bodyLarge?.copyWith(
                      color: palette.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    'Opening your dashboard…',
                    textAlign: TextAlign.center,
                    style: text.labelSmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Rings rippling behind the self-drawing check.
  Widget _buildCelebration(AppPalette palette) {
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          size: const Size.square(AppSizes.successCheck),
          painter: CallRingsPainter(
            color: palette.accent,
            ringProgress: [_firstRing.value, _secondRing.value],
          ),
          foregroundPainter: SuccessCheckPainter(
            circleProgress: _circle.value,
            checkProgress: _check.value,
            circleColor: palette.accent,
            checkColor: palette.onAccent,
          ),
        ),
      ),
    );
  }
}
