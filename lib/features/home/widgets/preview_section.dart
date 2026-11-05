import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/ui.dart';

/// A dashboard section: header with "See all", then the first [limit] items
/// of [value], with compact loading and error states.
class PreviewSection<T> extends StatelessWidget {
  /// Creates the section.
  const PreviewSection({
    super.key,
    required this.title,
    required this.value,
    required this.itemBuilder,
    required this.emptyText,
    required this.onSeeAll,
    required this.onRetry,
    this.limit = 2,
  });

  /// Section title.
  final String title;

  /// Items to preview.
  final AsyncValue<List<T>> value;

  /// Builds one item.
  final Widget Function(T item) itemBuilder;

  /// Shown when there are no items.
  final String emptyText;

  /// Opens the full screen.
  final VoidCallback onSeeAll;

  /// Loads again after an error.
  final VoidCallback onRetry;

  /// How many items to show.
  final int limit;

  /// Builds the header and preview.
  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: title,
          trailing: TextButton(
            onPressed: onSeeAll,
            child: Text('See all', semanticsLabel: 'See all: $title'),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        ...switch (value) {
          AsyncData(:final value) when value.isEmpty => [
            Text(emptyText, style: text.bodySmall),
          ],
          AsyncData(:final value) => [
            for (final item in value.take(limit)) ...[
              itemBuilder(item),
              const SizedBox(height: AppSpacing.xs),
            ],
          ],
          AsyncError() => [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Couldn't load $title.",
                    style: text.bodySmall?.copyWith(
                      color: context.palette.error,
                    ),
                  ),
                ),
                TextButton(onPressed: onRetry, child: const Text('Retry')),
              ],
            ),
          ],
          _ => [
            const ClipRRect(
              borderRadius: AppRadius.pill,
              child: LinearProgressIndicator(
                minHeight: AppSizes.progressBarHeight,
              ),
            ),
          ],
        },
      ],
    );
  }
}
