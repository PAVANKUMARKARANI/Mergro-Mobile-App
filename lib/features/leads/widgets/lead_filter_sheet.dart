import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/ui.dart';
import '../controllers/leads_controller.dart';
import '../leads_demo_data.dart';
import '../models/lead.dart';
import '../models/lead_filters.dart';

/// Screen 11: source, status, territory and date filters. Changes apply as
/// they are made; [onDone] closes the sheet.
class LeadFilterSheet extends ConsumerWidget {
  /// Creates the sheet.
  const LeadFilterSheet({super.key, required this.onDone});

  /// Closes the sheet.
  final VoidCallback onDone;

  /// Builds the filter groups and actions.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(leadFiltersProvider);
    final controller = ref.read(leadFiltersProvider.notifier);
    final matching = ref.watch(
      filteredLeadsProvider.select((leads) => leads.value?.length),
    );
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              children: [
                const SectionHeader(title: 'Filter leads', isLarge: true),
                const SizedBox(height: AppSpacing.md),
                ToggleChipGroup<LeadSource>(
                  label: 'Source',
                  options: LeadSource.values,
                  selected: filters.sources,
                  labelOf: (source) => source.label,
                  onToggled: controller.toggleSource,
                ),
                const SizedBox(height: AppSpacing.lg),
                ToggleChipGroup<LeadStatus>(
                  label: 'Status',
                  options: LeadStatus.values,
                  selected: filters.statuses,
                  labelOf: (status) => status.label,
                  onToggled: controller.toggleStatus,
                ),
                const SizedBox(height: AppSpacing.lg),
                ToggleChipGroup<String>(
                  label: 'Territory',
                  options: LeadsDemoData.areas,
                  selected: filters.areas,
                  labelOf: (area) => area,
                  onToggled: controller.toggleArea,
                ),
                const SizedBox(height: AppSpacing.lg),
                ToggleChipGroup<LeadDateRange>(
                  label: 'Captured',
                  options: LeadDateRange.values,
                  selected: {filters.dateRange},
                  labelOf: (range) => range.label,
                  onToggled: controller.setDateRange,
                ),
              ],
            ),
          ),
          BottomActionBar(
            onBack: filters.sheetFilterCount == 0
                ? null
                : controller.clearSheetFilters,
            backLabel: 'Clear',
            continueLabel: matching == null
                ? 'Show leads'
                : 'Show $matching lead${matching == 1 ? '' : 's'}',
            onContinue: onDone,
          ),
        ],
      ),
    );
  }
}
