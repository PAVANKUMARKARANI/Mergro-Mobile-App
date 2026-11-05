/// Human-friendly date and duration labels used across the app.
abstract final class TimeFormat {
  static const List<String> _weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// How long ago [time] was: "Just now", "3 min ago", "2 h ago",
  /// "Yesterday", or a date like "5 Nov".
  static String ago(DateTime time, DateTime now) {
    final elapsed = now.difference(time);
    if (elapsed.inMinutes < 1) return 'Just now';
    if (elapsed.inMinutes < 60) return '${elapsed.inMinutes} min ago';
    if (elapsed.inHours < 24 && _isSameDay(time, now)) {
      return '${elapsed.inHours} h ago';
    }
    if (_isSameDay(time, now.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    }
    return shortDate(time);
  }

  /// Elapsed time as a stopwatch: "0:42", "12:05" or "1:02:05".
  static String stopwatch(Duration duration) {
    final safe = duration.isNegative ? Duration.zero : duration;
    final hours = safe.inHours;
    final minutes = safe.inMinutes.remainder(60);
    final seconds = _two(safe.inSeconds.remainder(60));
    return hours > 0 ? '$hours:${_two(minutes)}:$seconds' : '$minutes:$seconds';
  }

  /// 12-hour clock time: "9:05 AM".
  static String clock(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final suffix = time.hour < 12 ? 'AM' : 'PM';
    return '$hour:${_two(time.minute)} $suffix';
  }

  /// "Today", "Tomorrow", "Yesterday" or "Mon 10 Nov".
  static String day(DateTime day, DateTime now) {
    if (_isSameDay(day, now)) return 'Today';
    if (_isSameDay(day, now.add(const Duration(days: 1)))) return 'Tomorrow';
    if (_isSameDay(day, now.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    }
    return '${_weekdays[day.weekday - 1]} ${shortDate(day)}';
  }

  /// Day and month: "5 Nov".
  static String shortDate(DateTime time) =>
      '${time.day} ${_months[time.month - 1]}';

  /// Seconds as "42 s" or "1 m 05 s".
  static String seconds(int totalSeconds) {
    if (totalSeconds < 60) return '$totalSeconds s';
    return '${totalSeconds ~/ 60} m ${_two(totalSeconds % 60)} s';
  }

  /// True when [a] and [b] fall on the same calendar day.
  static bool isSameDay(DateTime a, DateTime b) => _isSameDay(a, b);

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String _two(int value) => value.toString().padLeft(2, '0');
}
