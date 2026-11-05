import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/ui.dart';
import '../controllers/leads_controller.dart';
import '../models/lead.dart';
import '../widgets/lead_tile.dart';

/// Screen 5 (with 11): every lead by source, status and score, with
/// search, Hot/Warm/Cold chips and a filter sheet.
class LeadsScreen extends ConsumerStatefulWidget {
  /// Creates the screen with its navigation callback.
  const LeadsScreen({super.key, required this.onOpenFilters});

  /// Opens the filter sheet (screen 11).
  final VoidCallback onOpenFilters;

  /// Creates the state owning the search field controller.
  @override
  ConsumerState<LeadsScreen> createState() => _LeadsScreenState();
}

/// Owns the search text controller.
class _LeadsScreenState extends ConsumerState<LeadsScreen> {
  late final TextEditingController _searchController = TextEditingController(
    text: ref.read(leadFiltersProvider).query,
  );

  /// Releases the search controller.
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Builds the search bar, chips and list.
  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(leadFiltersProvider);
    final filterController = ref.read(leadFiltersProvider.notifier);
    final allLeads = ref.watch(leadsControllerProvider).value ?? const [];
    final sheetCount = filters.sheetFilterCount;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leads'),
        actions: [
          IconButton(
            tooltip: sheetCount == 0
                ? 'Filters'
                : 'Filters, $sheetCount active',
            onPressed: widget.onOpenFilters,
            icon: Badge(
              isLabelVisible: sheetCount > 0,
              label: Text('$sheetCount'),
              child: const Icon(LucideIcons.slidersHorizontal),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: AppTextField(
              label: 'Search leads',
              hint: 'Name, phone or area',
              controller: _searchController,
              prefixIcon: LucideIcons.search,
              textInputAction: TextInputAction.search,
              onChanged: filterController.setQuery,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: ToggleChipGroup<LeadTemperature>(
              options: LeadTemperature.values,
              selected: filters.temperatures,
              labelOf: (band) {
                final count = allLeads.where((l) => l.temperature == band);
                return '${band.label} (${count.length})';
              },
              onToggled: (band) => filterController.showOnly(
                filters.temperatures.contains(band) ? null : band,
              ),
            ),
          ),
          Expanded(child: _buildList(filters.isFiltering)),
        ],
      ),
    );
  }

  /// The lead list in its loading / empty / error / data state.
  Widget _buildList(bool isFiltering) {
    final leads = ref.watch(filteredLeadsProvider);
    final controller = ref.read(leadsControllerProvider.notifier);
    return AsyncValueView<List<Lead>>(
      value: leads,
      onRetry: controller.refresh,
      isEmpty: (items) => items.isEmpty && !isFiltering,
      emptyIcon: LucideIcons.users,
      emptyTitle: 'No leads yet',
      emptyMessage: 'New leads from your sources appear here within seconds.',
      builder: (items) => RefreshIndicator(
        onRefresh: controller.refresh,
        child: items.isEmpty ? _noMatches() : _leadList(items),
      ),
    );
  }

  /// Scrollable list of [items] with a count header.
  Widget _leadList(List<Lead> items) {
    final now = DateTime.now();
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.xl,
      ),
      itemCount: items.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
      itemBuilder: (context, index) => index == 0
          ? Text(
              '${items.length} lead${items.length == 1 ? '' : 's'} · newest first',
              style: context.textStyles.labelSmall,
            )
          : LeadTile(lead: items[index - 1], now: now),
    );
  }

  /// Empty state for filters that match nothing, with a reset.
  Widget _noMatches() {
    return ListView(
      children: [
        EmptyState(
          icon: LucideIcons.searchX,
          title: 'No leads match',
          message: 'Try a different search or clear the filters.',
          action: AppButton(
            label: 'Clear filters',
            variant: AppButtonVariant.secondary,
            expand: false,
            onPressed: () {
              _searchController.clear();
              ref.read(leadFiltersProvider.notifier).clearAll();
            },
          ),
        ),
      ],
    );
  }
}
