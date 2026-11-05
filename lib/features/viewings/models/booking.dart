import 'package:flutter/foundation.dart';

/// A listing a viewing can be booked for.
@immutable
class PropertyOption {
  /// Creates an option.
  const PropertyOption({
    required this.id,
    required this.title,
    required this.address,
    required this.price,
  });

  /// Stable id.
  final String id;

  /// e.g. "3 BHK · Prestige Lakeside".
  final String title;

  /// Short address.
  final String address;

  /// Price label.
  final String price;
}

/// A start time and whether it is free.
@immutable
class ViewingSlot {
  /// Creates a slot.
  const ViewingSlot({required this.start, required this.isAvailable});

  /// Start time.
  final DateTime start;

  /// False when booked by someone else or in the past.
  final bool isAvailable;
}

/// State of the Book viewing screen (18).
@immutable
class BookViewingState {
  /// Creates a state.
  const BookViewingState({
    required this.properties,
    required this.days,
    required this.day,
    required this.slots,
    this.propertyId,
    this.heldSlot,
    this.holdUntil,
    this.isHolding = false,
    this.isBooking = false,
    this.errorMessage,
  });

  /// Listings matching the lead.
  final List<PropertyOption> properties;

  /// Days offered (today + 6).
  final List<DateTime> days;

  /// Selected day.
  final DateTime day;

  /// Slots of [day].
  final List<ViewingSlot> slots;

  /// Selected property id.
  final String? propertyId;

  /// Slot currently held for this agent.
  final DateTime? heldSlot;

  /// When the hold expires.
  final DateTime? holdUntil;

  /// True while a hold request runs.
  final bool isHolding;

  /// True while the booking request runs.
  final bool isBooking;

  /// Why the last action failed, or null.
  final String? errorMessage;

  /// The selected property, if any.
  PropertyOption? get property =>
      properties.where((p) => p.id == propertyId).firstOrNull;

  /// Copies with changes; nullable fields take getters so they can be
  /// cleared.
  BookViewingState copyWith({
    DateTime? day,
    List<ViewingSlot>? slots,
    ValueGetter<String?>? propertyId,
    ValueGetter<DateTime?>? heldSlot,
    ValueGetter<DateTime?>? holdUntil,
    bool? isHolding,
    bool? isBooking,
    ValueGetter<String?>? errorMessage,
  }) {
    return BookViewingState(
      properties: properties,
      days: days,
      day: day ?? this.day,
      slots: slots ?? this.slots,
      propertyId: propertyId != null ? propertyId() : this.propertyId,
      heldSlot: heldSlot != null ? heldSlot() : this.heldSlot,
      holdUntil: holdUntil != null ? holdUntil() : this.holdUntil,
      isHolding: isHolding ?? this.isHolding,
      isBooking: isBooking ?? this.isBooking,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}
