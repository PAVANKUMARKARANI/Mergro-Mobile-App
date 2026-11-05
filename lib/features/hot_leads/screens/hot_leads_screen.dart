import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/ui.dart';
import '../controllers/hot_leads_controller.dart';
import '../models/handoff.dart';
import '../widgets/handoff_card.dart';

/// Screen 7: hot leads handed to the sales team, with SLA timers.
class HotLeadsScreen extends ConsumerWidget {
  /// Creates the screen.
  const HotLeadsScreen({super.key});

  /// Builds the inbox.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final handoffs = ref.watch(hotLeadsControllerProvider);
    final controller = ref.read(hotLeadsControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Hot lead inbox')),
      body: AsyncValueView<List<Handoff>>(
        value: handoffs,
        onRetry: controller.refresh,
        isEmpty: (items) => items.isEmpty,
        emptyIcon: LucideIcons.flame,
        emptyTitle: 'No hot leads waiting',
        emptyMessage:
            "You'll get a push alert the moment the AI hands one over.",
        builder: (items) {
          final waiting = items
              .where((item) => item.status == HandoffStatus.waiting)
              .length;
          return RefreshIndicator(
            onRefresh: controller.refresh,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                AppSpacing.xl,
              ),
              itemCount: items.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Text(
                    waiting == 0
                        ? 'All handoffs accepted.'
                        : '$waiting waiting · accept within 5 minutes',
                    style: context.textStyles.labelSmall,
                  );
                }
                final handoff = items[index - 1];
                return HandoffCard(
                  handoff: handoff,
                  onAccept: () => controller.accept(handoff.id),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
