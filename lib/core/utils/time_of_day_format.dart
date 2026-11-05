import 'package:flutter/material.dart';

/// Formatting and comparison helpers for [TimeOfDay].
extension TimeOfDayLabel on TimeOfDay {
  /// Minutes since midnight, for comparisons.
  int get minutesOfDay => hour * 60 + minute;

  /// 24-hour "HH:mm" label, e.g. "09:00".
  String get label24 =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}
