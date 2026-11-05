import '../leads/models/lead.dart';
import 'models/booking.dart';

/// Sample listings and calendar slots until `GET /api/viewings/slots`
/// exists.
abstract final class BookingDemoData {
  /// How long a slot is held while the agent confirms.
  static const Duration holdDuration = Duration(minutes: 5);

  /// First and last slot hours of a day (calling-hours friendly).
  static const int firstHour = 10;

  /// Last slot start hour.
  static const int lastHour = 18;

  /// Time zone shown next to the slots.
  static const String timeZoneLabel = 'Asia/Kolkata (IST)';

  /// Three listings in the lead's area that fit their property type.
  static List<PropertyOption> propertiesFor(Lead lead) {
    const names = ['Prestige Lakeside', 'Brigade Meadows', 'Sobha Dream Acres'];
    final type = lead.propertyType.replaceAll(' apartment', '');
    return [
      for (final (index, name) in names.indexed)
        PropertyOption(
          id: 'listing-${lead.id}-$index',
          title: '$type · $name',
          address: '${['5th', '6th', '8th'][index]} Block, ${lead.area}',
          price: lead.budget,
        ),
    ];
  }

  /// Today and the next six days (midnight).
  static List<DateTime> daysFrom(DateTime now) => [
    for (var offset = 0; offset < 7; offset++)
      DateTime(now.year, now.month, now.day + offset),
  ];

  /// Hourly slots of [day]; a fixed pattern is taken, and past ones are not
  /// available.
  static List<ViewingSlot> slotsFor(DateTime day, DateTime now) => [
    for (var hour = firstHour; hour <= lastHour; hour++)
      ViewingSlot(
        start: DateTime(day.year, day.month, day.day, hour),
        isAvailable:
            (day.day + hour) % 3 != 0 &&
            DateTime(day.year, day.month, day.day, hour).isAfter(now),
      ),
  ];
}
