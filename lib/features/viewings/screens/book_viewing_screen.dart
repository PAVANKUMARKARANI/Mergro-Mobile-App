import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/ui.dart';
import '../../lead_detail/models/lead_profile.dart';
import '../booking_demo_data.dart';
import '../controllers/book_viewing_controller.dart';
import '../widgets/slot_picker.dart';

/// Screen 18: book a viewing for a lead — listing, day, a slot held for
/// 5 minutes, then confirm.
class BookViewingScreen extends ConsumerWidget {
  /// Creates the screen for [leadId].
  const BookViewingScreen({
    super.key,
    required this.leadId,
    required this.onBooked,
  });

  /// The lead the viewing is for.
  final String leadId;

  /// Called with the confirmation text once booked (wired by AppRoutes).
  final ValueChanged<String> onBooked;

  /// Books the held slot and reports the outcome.
  Future<void> _confirm(BuildContext context, WidgetRef ref) async {
    final outcome = await ref
        .read(bookViewingControllerProvider(leadId).notifier)
        .confirm();
    if (!context.mounted) return;
    if (outcome case LeadActionSucceeded(:final message)) onBooked(message);
  }

  /// Builds the screen.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = bookViewingControllerProvider(leadId);
    final booking = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    final now = DateTime.now();
    final held = booking.heldSlot;
    final holdUntil = booking.holdUntil;
    final error = booking.errorMessage;
    return Scaffold(
      appBar: AppBar(title: const Text('Book a viewing')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.md,
          AppSpacing.xl,
        ),
        children: [
          const SectionHeader(title: 'Listing'),
          const SizedBox(height: AppSpacing.xs),
          for (final property in booking.properties) ...[
            SelectableCard(
              title: property.title,
              subtitle: '${property.address} · ${property.price}',
              icon: LucideIcons.house,
              isSelected: property.id == booking.propertyId,
              onTap: () => controller.selectProperty(property.id),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          const SizedBox(height: AppSpacing.md),
          const SectionHeader(title: 'Day'),
          const SizedBox(height: AppSpacing.xs),
          ToggleChipGroup<DateTime>(
            options: booking.days,
            selected: {booking.day},
            labelOf: (day) => TimeFormat.day(day, now),
            onToggled: controller.selectDay,
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionHeader(
            title: 'Time',
            subtitle:
                '${BookingDemoData.timeZoneLabel}. Tap a time to hold it '
                'for 5 minutes.',
          ),
          const SizedBox(height: AppSpacing.xs),
          SlotPicker(
            slots: booking.slots,
            heldSlot: held,
            onSelected: booking.isHolding || booking.isBooking
                ? null
                : controller.holdSlot,
          ),
          if (booking.isHolding) ...[
            const SizedBox(height: AppSpacing.sm),
            const LinearProgressIndicator(),
          ],
          if (held != null && holdUntil != null) ...[
            const SizedBox(height: AppSpacing.md),
            HoldBanner(slot: held, holdUntil: holdUntil),
          ],
          if (error != null) ...[
            const SizedBox(height: AppSpacing.md),
            InfoBanner(type: InfoBannerType.error, message: error),
          ],
        ],
      ),
      bottomNavigationBar: BottomActionBar(
        continueLabel: 'Confirm viewing',
        isLoading: booking.isBooking,
        onContinue: held == null ? null : () => _confirm(context, ref),
      ),
    );
  }
}
