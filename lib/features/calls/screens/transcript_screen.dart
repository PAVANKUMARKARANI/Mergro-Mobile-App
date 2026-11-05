import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/ui.dart';
import '../controllers/call_providers.dart';
import '../models/call_transcript.dart';
import '../widgets/transcript_view.dart';

/// Screen 15: the full transcript of a finished call, personal data masked.
/// Audio playback is not part of this version (it needs an approved audio
/// package and recordings from the backend).
class TranscriptScreen extends ConsumerWidget {
  /// Creates the screen for [callId].
  const TranscriptScreen({super.key, required this.callId});

  /// The call whose transcript is shown.
  final String callId;

  /// Builds the screen.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(callDetailProvider(callId));
    return Scaffold(
      appBar: AppBar(title: const Text('Transcript')),
      body: AsyncValueView<CallDetail>(
        value: detail,
        onRetry: () => ref.invalidate(callDetailProvider(callId)),
        isEmpty: (data) => data.transcript.isEmpty,
        emptyIcon: LucideIcons.phoneMissed,
        emptyTitle: 'No transcript',
        emptyMessage: 'Nobody answered this call.',
        builder: (data) => ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
            AppSpacing.xl,
          ),
          children: [
            Text(
              'AI call with ${data.leadName} · ${data.transcript.length} lines. '
              'Phone numbers and emails are masked.',
              style: context.textStyles.bodySmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            // TODO(backend): GET /api/calls/{id}/recording and an approved
            // audio package to play the recording in sync with these lines.
            TranscriptView(lines: data.transcript),
          ],
        ),
      ),
    );
  }
}
