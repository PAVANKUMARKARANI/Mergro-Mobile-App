import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/ui.dart';
import '../calls_demo_data.dart';
import '../controllers/live_calls_controller.dart';
import '../models/live_call.dart';
import '../widgets/live_call_tiles.dart';

/// Screen 6: AI calls in progress and the dial queue.
class LiveCallsScreen extends ConsumerWidget {
  /// Creates the screen.
  const LiveCallsScreen({super.key, required this.onOpenCall});

  /// Opens the live call monitor (screen 12) by call id.
  final ValueChanged<String> onOpenCall;

  /// Builds the summary and both lists.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(liveCallsControllerProvider);
    final controller = ref.read(liveCallsControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Live calls')),
      body: AsyncValueView<LiveCallsSnapshot>(
        value: snapshot,
        onRetry: controller.refresh,
        isEmpty: (data) => data.active.isEmpty && data.queue.isEmpty,
        emptyIcon: LucideIcons.phoneCall,
        emptyTitle: 'No calls right now',
        emptyMessage: 'The AI calls every new lead within 60 seconds.',
        builder: (data) => RefreshIndicator(
          onRefresh: controller.refresh,
          child: _CallsList(snapshot: data, onOpenCall: onOpenCall),
        ),
      ),
    );
  }
}

/// Summary tiles, then active calls, then the queue.
class _CallsList extends StatelessWidget {
  /// Creates the list.
  const _CallsList({required this.snapshot, required this.onOpenCall});

  /// Calls to show.
  final LiveCallsSnapshot snapshot;

  /// Opens a call's monitor.
  final ValueChanged<String> onOpenCall;

  /// Builds the list.
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final latency = snapshot.averageLatencyMs;
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
                label: 'On a call',
                value: '${snapshot.active.length}',
                icon: LucideIcons.phoneCall,
                tone: StatusTone.success,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: MetricTile(
                label: 'In queue',
                value: '${snapshot.queue.length}',
                icon: LucideIcons.listOrdered,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: MetricTile(
                label: 'Avg AI reply',
                value: latency == null ? '–' : '$latency ms',
                icon: LucideIcons.timer,
                tone:
                    latency != null && latency < CallsDemoData.naturalLatencyMs
                    ? StatusTone.success
                    : StatusTone.warning,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        SectionHeader(
          title: 'In progress (${snapshot.active.length})',
          subtitle: 'Live transcript and stage of every AI call.',
        ),
        const SizedBox(height: AppSpacing.xs),
        if (snapshot.active.isEmpty)
          Text('No calls in progress.', style: context.textStyles.bodySmall),
        for (final call in snapshot.active) ...[
          LiveCallTile(call: call, onOpen: () => onOpenCall(call.id)),
          const SizedBox(height: AppSpacing.xs),
        ],
        const SizedBox(height: AppSpacing.md),
        SectionHeader(title: 'Dial queue (${snapshot.queue.length})'),
        const SizedBox(height: AppSpacing.xs),
        if (snapshot.queue.isEmpty)
          Text('Nobody is waiting.', style: context.textStyles.bodySmall),
        for (final entry in snapshot.queue) ...[
          QueuedCallTile(entry: entry, now: now),
          const SizedBox(height: AppSpacing.xs),
        ],
      ],
    );
  }
}
