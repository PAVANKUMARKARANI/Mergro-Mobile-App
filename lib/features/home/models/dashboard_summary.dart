import 'package:flutter/foundation.dart';

/// Today's headline numbers for the Home dashboard.
@immutable
class DashboardSummary {
  /// Creates a summary.
  const DashboardSummary({
    required this.speedToLeadSeconds,
    required this.newLeadsToday,
    required this.qualifiedToday,
    required this.contactRatePercent,
    this.speedToLeadTargetSeconds = 60,
  });

  /// 95th-percentile time from lead capture to AI call today; null until
  /// AI calls are being made (Voice AI phase).
  final int? speedToLeadSeconds;

  /// The speed-to-lead target.
  final int speedToLeadTargetSeconds;

  /// Leads captured today.
  final int newLeadsToday;

  /// Leads qualified today.
  final int qualifiedToday;

  /// Share of today's leads the AI reached, 0–100.
  final int contactRatePercent;

  /// True when speed-to-lead is known and meets the target.
  bool get isOnTarget {
    final seconds = speedToLeadSeconds;
    return seconds != null && seconds <= speedToLeadTargetSeconds;
  }
}
