import 'package:flutter_test/flutter_test.dart';
import 'package:mergro_ai_voice_assistant/core/utils/time_format.dart';

void main() {
  final now = DateTime(2026, 11, 5, 15, 30);

  test('ago covers minutes, hours, yesterday and older dates', () {
    expect(
      TimeFormat.ago(now.subtract(const Duration(seconds: 20)), now),
      'Just now',
    );
    expect(
      TimeFormat.ago(now.subtract(const Duration(minutes: 7)), now),
      '7 min ago',
    );
    expect(
      TimeFormat.ago(now.subtract(const Duration(hours: 3)), now),
      '3 h ago',
    );
    expect(TimeFormat.ago(DateTime(2026, 11, 4, 22), now), 'Yesterday');
    expect(TimeFormat.ago(DateTime(2026, 10, 28), now), '28 Oct');
  });

  test('stopwatch pads seconds and adds hours when needed', () {
    expect(TimeFormat.stopwatch(const Duration(seconds: 42)), '0:42');
    expect(
      TimeFormat.stopwatch(const Duration(minutes: 12, seconds: 5)),
      '12:05',
    );
    expect(
      TimeFormat.stopwatch(const Duration(hours: 1, seconds: 65)),
      '1:01:05',
    );
    expect(TimeFormat.stopwatch(const Duration(seconds: -3)), '0:00');
  });

  test('clock, day and seconds labels', () {
    expect(TimeFormat.clock(DateTime(2026, 11, 5, 9, 5)), '9:05 AM');
    expect(TimeFormat.clock(DateTime(2026, 11, 5, 0, 0)), '12:00 AM');
    expect(TimeFormat.clock(DateTime(2026, 11, 5, 17, 30)), '5:30 PM');
    expect(TimeFormat.day(DateTime(2026, 11, 5, 8), now), 'Today');
    expect(TimeFormat.day(DateTime(2026, 11, 6, 8), now), 'Tomorrow');
    expect(TimeFormat.day(DateTime(2026, 11, 9), now), 'Mon 9 Nov');
    expect(TimeFormat.seconds(42), '42 s');
    expect(TimeFormat.seconds(65), '1 m 05 s');
  });
}
