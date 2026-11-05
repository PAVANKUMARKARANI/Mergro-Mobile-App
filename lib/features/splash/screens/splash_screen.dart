import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/ui.dart';
import '../controllers/splash_controller.dart';
import '../models/splash_destination.dart';
import '../widgets/splash_timeline.dart';
import '../widgets/splash_view.dart';

/// Animated splash. Calls [onFinished] once BOTH the animation has finished
/// and the destination is known.
class SplashScreen extends ConsumerStatefulWidget {
  /// Creates the splash with its navigation callback.
  const SplashScreen({super.key, required this.onFinished});

  /// Called exactly once with the resolved destination.
  final ValueChanged<SplashDestination> onFinished;

  /// Creates the state owning the animation controller.
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

/// Owns the animation controller and the reduced-motion hold timer.
class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.splash,
  );
  late final SplashTimeline _timeline = SplashTimeline(_controller);
  Timer? _reducedMotionTimer;
  bool _isAnimationDone = false;
  bool _hasStarted = false;
  bool _hasFinished = false;

  /// Starts the animation once [MediaQuery] is available, so the
  /// reduced-motion setting can be read.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasStarted) return;
    _hasStarted = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
      _reducedMotionTimer = Timer(
        AppDurations.reducedMotionSplashHold,
        _markAnimationDone,
      );
    } else {
      _controller.forward().whenComplete(_markAnimationDone);
    }
  }

  /// Releases the controller and timer.
  @override
  void dispose() {
    _reducedMotionTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Records that the visuals are complete and tries to leave.
  void _markAnimationDone() {
    if (!mounted) return;
    _isAnimationDone = true;
    _finishIfReady(ref.read(splashControllerProvider).value);
  }

  /// Leaves the splash when the animation is done and [destination] is known.
  void _finishIfReady(SplashDestination? destination) {
    if (_hasFinished || !_isAnimationDone || destination == null) return;
    _hasFinished = true;
    widget.onFinished(destination);
  }

  /// Builds the splash with light status-bar icons.
  @override
  Widget build(BuildContext context) {
    ref.listen(splashControllerProvider, (_, next) {
      _finishIfReady(next.value);
    });
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.splashNavy,
        body: SplashView(timeline: _timeline),
      ),
    );
  }
}
