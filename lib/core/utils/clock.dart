import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The current time, ticking once a second while anything watches it.
/// Drives call timers and SLA countdowns; overridden in tests for stable
/// output.
final clockProvider = StreamProvider.autoDispose<DateTime>((ref) async* {
  yield DateTime.now();
  yield* Stream<DateTime>.periodic(
    const Duration(seconds: 1),
    (_) => DateTime.now(),
  );
});
