import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/ui.dart';
import '../controllers/viewings_controller.dart';
import '../models/viewing.dart';
import '../widgets/viewing_tile.dart';

/// Screen 8: booked viewings for today, tomorrow or the week, by day.
class ViewingsScreen extends ConsumerWidget {
  /// Creates the screen.
  const ViewingsScreen({super.key, required this.onOpenLead});

  /// Opens the lead's profile (screen 13) by id.
  final ValueChanged<String> onOpenLead;

  /// Builds the range chips and the grouped list.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewings = ref.watch(viewingsControllerProvider);
    final controller = ref.read(viewingsControllerProvider.notifier);
    final range = ref.watch(viewingRangeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Viewings')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: ToggleChipGroup<ViewingRange>(
              options: ViewingRange.values,
              selected: {range},
              labelOf: (option) => option.label,
              onToggled: ref.read(viewingRangeProvider.notifier).select,
            ),
          ),
          Expanded(
            child: AsyncValueView<List<Viewing>>(
              value: viewings,
              onRetry: controller.refresh,
              builder: (items) => RefreshIndicator(
                onRefresh: controller.refresh,
                child: _ViewingList(
                  viewings: items,
                  range: range,
                  onOpenLead: onOpenLead,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Viewings in [range], grouped under day headers.
class _ViewingList extends StatelessWidget {
  /// Creates the list.
  const _ViewingList({
    required this.viewings,
    required this.range,
    required this.onOpenLead,
  });

  /// All loaded viewings, earliest first.
  final List<Viewing> viewings;

  /// Selected range.
  final ViewingRange range;

  /// Opens a lead's profile.
  final ValueChanged<String> onOpenLead;

  /// Builds the list or an empty state.
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final shown = viewings
        .where((viewing) => isInViewingRange(viewing, range, now))
        .toList();
    if (shown.isEmpty) {
      return ListView(
        children: [
          EmptyState(
            icon: LucideIcons.calendarDays,
            title: 'No viewings ${range.label.toLowerCase()}',
            message:
                'Viewings the AI books appear here with the lead and host.',
          ),
        ],
      );
    }
    final children = <Widget>[];
    String? lastDay;
    for (final viewing in shown) {
      final day = TimeFormat.day(viewing.startsAt, now);
      if (day != lastDay) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.sm,
              bottom: AppSpacing.xs,
            ),
            child: Text(day, style: context.textStyles.labelMedium),
          ),
        );
        lastDay = day;
      }
      children
        ..add(
          ViewingTile(
            viewing: viewing,
            onOpen: () => onOpenLead(viewing.leadId),
          ),
        )
        ..add(const SizedBox(height: AppSpacing.xs));
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.xl,
      ),
      children: children,
    );
  }
}
