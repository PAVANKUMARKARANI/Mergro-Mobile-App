import '../../../shared/ui.dart';
import '../models/lead_insights.dart';

/// Screen 16: the five qualification answers with the AI's confidence.
class QualificationCard extends StatelessWidget {
  /// Creates the card.
  const QualificationCard({super.key, required this.fields});

  /// Answers in question order.
  final List<QualificationField> fields;

  /// Builds the card.
  @override
  Widget build(BuildContext context) {
    final hasAnswers = fields.any((field) => field.isAnswered);
    return SurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          if (!hasAnswers)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                'The AI asks these on the first call.',
                style: context.textStyles.bodySmall,
              ),
            ),
          for (final (index, field) in fields.indexed) ...[
            if (index > 0) const Divider(height: AppSizes.borderThin),
            _FieldRow(field: field),
          ],
        ],
      ),
    );
  }
}

/// One answer: label, value and a confidence bar.
class _FieldRow extends StatelessWidget {
  /// Creates the row.
  const _FieldRow({required this.field});

  /// The answer shown.
  final QualificationField field;

  /// Builds the row.
  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    final palette = context.palette;
    final value = field.value;
    final percent = (field.confidence * 100).round();
    return Semantics(
      label: value == null
          ? '${field.key.label}: not answered yet'
          : '${field.key.label}: $value, $percent percent confidence',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(field.key.label, style: text.bodySmall)),
                if (value != null) Text('$percent%', style: text.labelSmall),
              ],
            ),
            Text(
              value ?? 'Not answered yet',
              style: value == null
                  ? text.bodyMedium?.copyWith(color: palette.textSecondary)
                  : text.titleSmall,
            ),
            if (value != null) ...[
              const SizedBox(height: AppSpacing.xs),
              ClipRRect(
                borderRadius: AppRadius.pill,
                child: LinearProgressIndicator(
                  value: field.confidence,
                  minHeight: AppSizes.progressBarHeight,
                  color: field.confidence >= 0.75
                      ? palette.success
                      : palette.highlight,
                  backgroundColor: palette.border,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
