import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/clock.dart';
import '../../../shared/ui.dart';
import '../models/booking.dart';

/// Grid of hourly slots: taken or past ones are disabled, the held one is
/// filled.
class SlotPicker extends StatelessWidget {
  /// Creates the picker.
  const SlotPicker({
    super.key,
    required this.slots,
    required this.heldSlot,
    required this.onSelected,
  });

  /// Slots of the selected day.
  final List<ViewingSlot> slots;

  /// The slot held for this agent, if any.
  final DateTime? heldSlot;

  /// Holds a slot; null while a request runs.
  final ValueChanged<DateTime>? onSelected;

  /// Builds the grid.
  @override
  Widget build(BuildContext context) {
    if (!slots.any((slot) => slot.isAvailable)) {
      return Text(
        'No free times left on this day. Try another day.',
        style: context.textStyles.bodySmall,
      );
    }
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (final slot in slots)
          _SlotChip(
            slot: slot,
            isHeld: slot.start == heldSlot,
            onSelected: onSelected,
          ),
      ],
    );
  }
}

/// One slot button.
class _SlotChip extends StatelessWidget {
  /// Creates the chip.
  const _SlotChip({
    required this.slot,
    required this.isHeld,
    required this.onSelected,
  });

  /// The slot.
  final ViewingSlot slot;

  /// True when held for this agent.
  final bool isHeld;

  /// Holds the slot.
  final ValueChanged<DateTime>? onSelected;

  /// Width of a slot button.
  static const double width = 96;

  /// Builds the chip.
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final select = onSelected;
    final label = TimeFormat.clock(slot.start);
    return SizedBox(
      width: width,
      child: Semantics(
        selected: isHeld,
        label: slot.isAvailable ? label : '$label, not available',
        excludeSemantics: true,
        child: OutlinedButton(
          onPressed: slot.isAvailable && select != null && !isHeld
              ? () => select(slot.start)
              : null,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(width, AppSizes.minTouchTarget),
            padding: EdgeInsets.zero,
            backgroundColor: isHeld ? palette.accent : palette.surface,
            foregroundColor: isHeld ? palette.onAccent : palette.textPrimary,
            disabledForegroundColor: isHeld
                ? palette.onAccent
                : palette.textSecondary,
            disabledBackgroundColor: isHeld
                ? palette.accent
                : palette.background,
            side: BorderSide(color: isHeld ? palette.accent : palette.border),
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.buttonAll,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              decoration: slot.isAvailable ? null : TextDecoration.lineThrough,
            ),
          ),
        ),
      ),
    );
  }
}

/// Ticking "Held for you · 4:32 left" banner; red once the hold expired.
class HoldBanner extends ConsumerWidget {
  /// Creates the banner.
  const HoldBanner({super.key, required this.slot, required this.holdUntil});

  /// The held slot.
  final DateTime slot;

  /// When the hold expires.
  final DateTime holdUntil;

  /// Builds the banner.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(clockProvider).value ?? DateTime.now();
    final left = holdUntil.difference(now);
    final when = '${TimeFormat.day(slot, now)}, ${TimeFormat.clock(slot)}';
    if (left.isNegative) {
      return InfoBanner(
        type: InfoBannerType.error,
        title: 'Hold expired',
        message: '$when may now go to someone else. Pick a time again.',
      );
    }
    return InfoBanner(
      type: InfoBannerType.success,
      title: '$when held for you',
      message:
          '${TimeFormat.stopwatch(left)} left to confirm before the slot is released.',
    );
  }
}
