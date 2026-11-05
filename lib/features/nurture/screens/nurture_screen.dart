import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/ui.dart';
import '../controllers/nurture_controller.dart';
import '../models/nurture_enrollment.dart';
import '../widgets/enrollment_tile.dart';

/// Screen 9: follow-ups by SMS, WhatsApp, email and AI call.
class NurtureScreen extends ConsumerWidget {
  /// Creates the screen.
  const NurtureScreen({super.key});

  /// Builds the summary, status chips and list.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enrollments = ref.watch(nurtureControllerProvider);
    final controller = ref.read(nurtureControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Nurture')),
      body: AsyncValueView<List<NurtureEnrollment>>(
        value: enrollments,
        onRetry: controller.refresh,
        isEmpty: (items) => items.isEmpty,
        emptyIcon: LucideIcons.send,
        emptyTitle: 'No one in nurture',
        emptyMessage:
            'Warm, cold and unanswered leads join a follow-up journey here.',
        builder: (items) => RefreshIndicator(
          onRefresh: controller.refresh,
          child: _NurtureList(items: items),
        ),
      ),
    );
  }
}

/// Summary tiles, status filter and the filtered enrollments.
class _NurtureList extends ConsumerWidget {
  /// Creates the list.
  const _NurtureList({required this.items});

  /// Every enrollment.
  final List<NurtureEnrollment> items;

  /// Builds the list.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(nurtureStatusFilterProvider);
    final now = DateTime.now();
    int countOf(NurtureStatus status) =>
        items.where((item) => item.status == status).length;
    final dueToday = items.where((item) {
      final next = item.nextTouchAt;
      return next != null && TimeFormat.isSameDay(next, now);
    }).length;
    final shown = filter == null
        ? items
        : items.where((item) => item.status == filter).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.xl,
      ),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: MetricTile(
                label: 'Active',
                value: '${countOf(NurtureStatus.active)}',
                icon: LucideIcons.route,
                tone: StatusTone.info,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: MetricTile(
                label: 'Replied',
                value: '${countOf(NurtureStatus.replied)}',
                icon: LucideIcons.reply,
                tone: StatusTone.success,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: MetricTile(
                label: 'Due today',
                value: '$dueToday',
                icon: LucideIcons.calendarClock,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ToggleChipGroup<NurtureStatus>(
          options: NurtureStatus.values,
          selected: {?filter},
          labelOf: (status) => '${status.label} (${countOf(status)})',
          onToggled: ref.read(nurtureStatusFilterProvider.notifier).toggle,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (shown.isEmpty)
          EmptyState(
            icon: LucideIcons.listFilter,
            title: 'No ${filter?.label.toLowerCase()} journeys',
          ),
        for (final item in shown) ...[
          EnrollmentTile(enrollment: item, now: now),
          const SizedBox(height: AppSpacing.xs),
        ],
      ],
    );
  }
}
