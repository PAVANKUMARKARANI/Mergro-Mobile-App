import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_spacing.dart';
import 'app_button.dart';
import 'empty_state.dart';
import 'info_banner.dart';
import 'skeleton.dart';

/// Renders an [AsyncValue] as Loading (skeleton) → data | Empty | Error with
/// Retry (standards A11). Takes the value; never reads providers itself.
class AsyncValueView<T> extends StatelessWidget {
  /// Creates the view.
  const AsyncValueView({
    super.key,
    required this.value,
    required this.builder,
    required this.onRetry,
    this.isEmpty,
    this.emptyIcon = LucideIcons.inbox,
    this.emptyTitle = 'Nothing here yet',
    this.emptyMessage,
    this.loading,
  });

  /// The loading / data / error value.
  final AsyncValue<T> value;

  /// Builds the content for loaded, non-empty data.
  final Widget Function(T data) builder;

  /// Loads again after an error.
  final VoidCallback onRetry;

  /// Whether loaded data counts as empty; null means never empty.
  final bool Function(T data)? isEmpty;

  /// Icon of the empty state.
  final IconData emptyIcon;

  /// Title of the empty state.
  final String emptyTitle;

  /// Message of the empty state.
  final String? emptyMessage;

  /// Placeholder while loading; defaults to a [SkeletonList].
  final Widget? loading;

  /// Builds the state-specific content.
  @override
  Widget build(BuildContext context) {
    return switch (value) {
      AsyncData(:final value) when isEmpty?.call(value) ?? false => Center(
        child: SingleChildScrollView(
          child: EmptyState(
            icon: emptyIcon,
            title: emptyTitle,
            message: emptyMessage,
          ),
        ),
      ),
      AsyncData(:final value) => builder(value),
      AsyncError(:final error) => _ErrorView(
        message: error is ApiException
            ? error.message
            : ApiException.defaultMessages[ApiErrorKind.unexpected]!,
        onRetry: onRetry,
      ),
      _ => loading ?? const SkeletonList(),
    };
  }
}

/// Error banner with a Retry button.
class _ErrorView extends StatelessWidget {
  /// Creates the error view.
  const _ErrorView({required this.message, required this.onRetry});

  /// User-facing error text.
  final String message;

  /// Loads again.
  final VoidCallback onRetry;

  /// Builds the banner and button.
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InfoBanner(
              type: InfoBannerType.error,
              title: "Couldn't load this",
              message: message,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Retry',
              variant: AppButtonVariant.secondary,
              leading: const Icon(LucideIcons.rotateCw, size: AppSizes.iconMd),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
