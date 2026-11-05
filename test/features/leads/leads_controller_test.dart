import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mergro_ai_voice_assistant/features/leads/controllers/leads_controller.dart';
import 'package:mergro_ai_voice_assistant/features/leads/models/lead.dart';
import 'package:mergro_ai_voice_assistant/features/leads/models/lead_filters.dart';

/// A container with the leads loaded and the filtered list kept alive.
Future<ProviderContainer> _loaded() async {
  final container = ProviderContainer.test();
  container.listen(filteredLeadsProvider, (_, _) {});
  await container.read(leadsControllerProvider.future);
  return container;
}

/// Names of the leads currently shown.
List<String> _shown(ProviderContainer container) =>
    container.read(filteredLeadsProvider).value!.map((l) => l.name).toList();

void main() {
  test('score bands: 75+ hot, 45–74 warm, below 45 cold', () {
    expect(LeadTemperature.fromScore(75), LeadTemperature.hot);
    expect(LeadTemperature.fromScore(74), LeadTemperature.warm);
    expect(LeadTemperature.fromScore(45), LeadTemperature.warm);
    expect(LeadTemperature.fromScore(44), LeadTemperature.cold);
  });

  test('loads newest first', () async {
    final container = await _loaded();
    final leads = container.read(leadsControllerProvider).value!;
    for (var i = 1; i < leads.length; i++) {
      expect(leads[i - 1].createdAt.isAfter(leads[i].createdAt), isTrue);
    }
  });

  test('search matches name, area and phone digits', () async {
    final container = await _loaded();
    final filters = container.read(leadFiltersProvider.notifier);

    filters.setQuery('fatima');
    expect(_shown(container), ['Fatima Sheikh']);

    filters.setQuery('hebbal');
    expect(_shown(container), containsAll(['Meera Nair', 'Priyanka Reddy']));

    filters.setQuery('77310');
    expect(_shown(container), ['Fatima Sheikh']);
  });

  test('Hot chip, sheet filters and clearing', () async {
    final container = await _loaded();
    final filters = container.read(leadFiltersProvider.notifier);
    final all = _shown(container).length;

    filters.showOnly(LeadTemperature.hot);
    final hot = container.read(filteredLeadsProvider).value!;
    expect(hot, isNotEmpty);
    expect(hot.every((l) => l.temperature == LeadTemperature.hot), isTrue);

    filters
      ..toggleSource(LeadSource.facebook)
      ..toggleArea('Koramangala');
    expect(_shown(container), ['Ananya Iyer']);
    expect(container.read(leadFiltersProvider).sheetFilterCount, 2);

    filters.clearSheetFilters();
    expect(
      container.read(leadFiltersProvider).temperatures,
      isNotEmpty,
      reason: 'the Hot chip is not a sheet filter',
    );
    filters.clearAll();
    expect(_shown(container).length, all);
  });

  test('date range drops older leads', () async {
    final container = await _loaded();
    final filters = container.read(leadFiltersProvider.notifier)
      ..setDateRange(LeadDateRange.week);
    expect(
      _shown(container),
      isNot(contains('Lakshmi Pillai')),
      reason: 'captured 12 days ago',
    );
    filters.setDateRange(LeadDateRange.today);
    final now = DateTime.now();
    expect(
      container
          .read(filteredLeadsProvider)
          .value!
          .every((l) => now.difference(l.createdAt) <= const Duration(days: 1)),
      isTrue,
    );
  });
}
