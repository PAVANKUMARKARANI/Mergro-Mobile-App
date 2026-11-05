import 'package:flutter/material.dart';

/// Formatting and comparison helpers for [TimeOfDay].
extension TimeOfDayLabel on TimeOfDay {
  /// Minutes since midnight, for comparisons.
  int get minutesOfDay => hour * 60 + minute;

  /// 24-hour "HH:mm" label, e.g. "09:00".
  String get label24 =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

/// Parses a 24-hour "HH:mm" [label]; returns null when it is malformed.
TimeOfDay? parseTimeOfDay24(Object? label) {
  if (label is! String) return null;
  final match = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$').firstMatch(label);
  if (match == null) return null;
  return TimeOfDay(
    hour: int.parse(match.group(1)!),
    minute: int.parse(match.group(2)!),
  );
}
