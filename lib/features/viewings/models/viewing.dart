import 'package:flutter/foundation.dart';

/// State of a booked viewing.
enum ViewingStatus {
  /// Confirmed with the lead.
  confirmed('Confirmed'),

  /// Slot held; waiting for the lead to confirm.
  pending('Awaiting confirmation'),

  /// The lead showed up.
  completed('Completed'),

  /// The lead didn't show up.
  noShow('No-show');

  /// Creates a status with its label.
  const ViewingStatus(this.label);

  /// Display label.
  final String label;
}

/// Which viewings the list shows.
enum ViewingRange {
  /// Today only.
  today('Today'),

  /// Tomorrow only.
  tomorrow('Tomorrow'),

  /// Today plus the next 6 days.
  week('Next 7 days');

  /// Creates a range with its label.
  const ViewingRange(this.label);

  /// Display label.
  final String label;
}

/// A property viewing booked by the AI or an agent.
@immutable
class Viewing {
  /// Creates a viewing.
  const Viewing({
    required this.id,
    required this.leadName,
    required this.property,
    required this.address,
    required this.startsAt,
    required this.agentName,
    this.durationMinutes = 30,
    this.status = ViewingStatus.confirmed,
  });

  /// Stable id.
  final String id;

  /// Who is viewing.
  final String leadName;

  /// Property, e.g. "3 BHK · Prestige Lakeside".
  final String property;

  /// Short address.
  final String address;

  /// Start time.
  final DateTime startsAt;

  /// Agent hosting the viewing.
  final String agentName;

  /// Length in minutes.
  final int durationMinutes;

  /// Booking state.
  final ViewingStatus status;
}
