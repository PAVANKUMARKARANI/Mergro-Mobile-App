import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/ui.dart';
import '../../controllers/calendar_controller.dart';
import '../../models/onboarding_options.dart';
import '../../models/setup_drafts.dart';
import '../../onboarding_demo_data.dart';

/// Calendar step used twice: admin "Calendar for viewings" (with viewing
/// length and buffer) and agent "Calendar & availability".
class CalendarStep extends ConsumerWidget {
  /// Admin variant: brokerage viewing calendar.
  CalendarStep.viewings({super.key})
    : provider = viewingCalendarControllerProvider,
      showViewingOptions = true;

  /// Agent variant: personal availability.
  CalendarStep.availability({super.key})
    : provider = agentCalendarControllerProvider,
      showViewingOptions = false;

  /// Which draft this step edits.
  final NotifierProvider<CalendarController, CalendarDraft> provider;

  /// Shows viewing length and buffer (admin only).
  final bool showViewingOptions;

  /// Builds the step.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final calendar in CalendarProvider.values) ...[
          IntegrationCard(
            name: calendar.label,
            description: calendar.description,
            status: draft.statusOf(calendar),
            logo: const Icon(LucideIcons.calendar, size: AppSizes.iconMd),
            onConnect: () => controller.connect(calendar),
            onDisconnect: () => controller.disconnect(calendar),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (showViewingOptions) ..._buildViewingOptions(draft, controller),
        const SizedBox(height: AppSpacing.lg),
        ToggleChipGroup<int>(
          label: showViewingOptions ? 'Viewing days' : 'Working days',
          options: const [1, 2, 3, 4, 5, 6, 7],
          selected: draft.days,
          labelOf: (weekday) => OnboardingDemoData.weekdayLabels[weekday - 1],
          onToggled: controller.toggleDay,
        ),
        const SizedBox(height: AppSpacing.lg),
        TimeRangeField(
          label: showViewingOptions ? 'Viewing hours' : 'Working hours',
          start: draft.startTime,
          end: draft.endTime,
          onStartChanged: controller.setStartTime,
          onEndChanged: controller.setEndTime,
          errorText: draft.startTime.isBefore(draft.endTime)
              ? null
              : 'End time must be after start time.',
        ),
      ],
    );
  }

  /// Viewing length and buffer option cards.
  List<Widget> _buildViewingOptions(
    CalendarDraft draft,
    CalendarController controller,
  ) {
    return [
      const SizedBox(height: AppSpacing.md),
      const SectionHeader(title: 'Viewing length'),
      const SizedBox(height: AppSpacing.sm),
      _MinuteOptions(
        options: OnboardingDemoData.viewingLengths,
        selected: draft.viewingMinutes,
        onSelected: controller.setViewingMinutes,
      ),
      const SizedBox(height: AppSpacing.lg),
      const SectionHeader(
        title: 'Buffer between viewings',
        subtitle: 'Travel and prep time.',
      ),
      const SizedBox(height: AppSpacing.sm),
      _MinuteOptions(
        options: OnboardingDemoData.bufferOptions,
        selected: draft.bufferMinutes,
        onSelected: controller.setBufferMinutes,
      ),
    ];
  }
}

/// Row of equal-width SelectableCards for minute values.
class _MinuteOptions extends StatelessWidget {
  /// Creates the option row.
  const _MinuteOptions({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  /// Minute values.
  final List<int> options;

  /// Selected value.
  final int selected;

  /// Called with the tapped value.
  final ValueChanged<int> onSelected;

  /// Builds the row.
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < options.length; index++) ...[
          if (index > 0) const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: SelectableCard(
              title: '${options[index]} min',
              isSelected: options[index] == selected,
              onTap: () => onSelected(options[index]),
            ),
          ),
        ],
      ],
    );
  }
}
