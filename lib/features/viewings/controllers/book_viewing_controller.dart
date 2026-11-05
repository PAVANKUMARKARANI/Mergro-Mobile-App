import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_durations.dart';
import '../../../core/utils/time_format.dart';
import '../../auth/controllers/current_user_controller.dart';
import '../../lead_detail/controllers/lead_profile_controller.dart';
import '../../lead_detail/models/lead_profile.dart';
import '../../leads/leads_demo_data.dart';
import '../../leads/models/lead.dart';
import '../booking_demo_data.dart';
import '../models/booking.dart';
import '../models/viewing.dart';
import 'viewings_controller.dart';

/// Booking state for one lead (screen 18), by lead id.
final bookViewingControllerProvider = NotifierProvider.autoDispose
    .family<BookViewingController, BookViewingState, String>(
      BookViewingController.new,
    );

/// Picks a listing, day and slot, holds the slot for 5 minutes and books
/// it (simulated until the calendar API exists).
class BookViewingController extends Notifier<BookViewingState> {
  /// Creates the controller for [leadId].
  BookViewingController(this.leadId);

  /// The lead the viewing is for.
  final String leadId;

  /// The demo lead, if it exists.
  Lead? get _lead =>
      LeadsDemoData.leads(DateTime.now())
          .where((lead) => lead.id == leadId)
          .firstOrNull;

  /// Starts on today with the first listing selected.
  @override
  BookViewingState build() {
    // TODO(backend): GET /api/listings?leadId= and GET /api/viewings/slots
    // ?propertyId=&date= (agent calendars, no double-booking).
    final now = DateTime.now();
    final lead = _lead;
    final properties = lead == null
        ? const <PropertyOption>[]
        : BookingDemoData.propertiesFor(lead);
    final days = BookingDemoData.daysFrom(now);
    return BookViewingState(
      properties: properties,
      days: days,
      day: days.first,
      slots: BookingDemoData.slotsFor(days.first, now),
      propertyId: properties.firstOrNull?.id,
    );
  }

  /// Selects a listing (keeps any hold: it is for a time, not a listing).
  void selectProperty(String id) =>
      state = state.copyWith(propertyId: () => id, errorMessage: () => null);

  /// Shows [day]'s slots and releases any hold.
  void selectDay(DateTime day) {
    // TODO(backend): DELETE /api/viewings/hold/{id} when a hold is released.
    state = state.copyWith(
      day: day,
      slots: BookingDemoData.slotsFor(day, DateTime.now()),
      heldSlot: () => null,
      holdUntil: () => null,
      errorMessage: () => null,
    );
  }

  /// Holds [start] for 5 minutes. Returns false if it can't be held.
  Future<bool> holdSlot(DateTime start) async {
    final slot = state.slots.where((s) => s.start == start).firstOrNull;
    if (slot == null ||
        !slot.isAvailable ||
        state.isHolding ||
        state.isBooking) {
      return false;
    }
    state = state.copyWith(isHolding: true, errorMessage: () => null);
    // TODO(backend): POST /api/viewings/hold {propertyId, start} → hold id
    // and expiry; a 409 means someone else took the slot.
    await Future<void>.delayed(AppDurations.simulatedNetwork);
    if (!ref.mounted) return false;
    state = state.copyWith(
      isHolding: false,
      heldSlot: () => start,
      holdUntil: () => DateTime.now().add(BookingDemoData.holdDuration),
    );
    return true;
  }

  /// Books the held slot.
  Future<LeadActionOutcome> confirm() async {
    final start = state.heldSlot;
    final holdUntil = state.holdUntil;
    final property = state.property;
    final lead = _lead;
    if (state.isBooking) return const LeadActionFailed('Booking…');
    if (start == null ||
        holdUntil == null ||
        property == null ||
        lead == null) {
      return _fail('Pick a listing and a time first.');
    }
    if (DateTime.now().isAfter(holdUntil)) {
      state = state.copyWith(heldSlot: () => null, holdUntil: () => null);
      return _fail('The 5-minute hold ran out. Pick the time again.');
    }
    state = state.copyWith(isBooking: true, errorMessage: () => null);
    // TODO(backend): POST /api/viewings {holdId, leadId, propertyId} → also
    // sends the lead an SMS confirmation and updates the CRM.
    await Future<void>.delayed(AppDurations.simulatedNetwork);
    if (!ref.mounted) return const LeadActionFailed('Booking…');
    final viewing = Viewing(
      id: 'viewing-${DateTime.now().millisecondsSinceEpoch}',
      leadId: lead.id,
      leadName: lead.name,
      property: property.title,
      address: property.address,
      startsAt: start,
      agentName: _agentName(),
      status: ViewingStatus.pending,
    );
    _share(viewing);
    state = state.copyWith(isBooking: false);
    return LeadActionSucceeded(
      'Viewing booked for ${TimeFormat.day(start, DateTime.now())}, '
      '${TimeFormat.clock(start)}. ${lead.name.split(' ').first} gets an '
      'SMS to confirm.',
    );
  }

  /// Records [message] as the error and returns it as a failure.
  LeadActionOutcome _fail(String message) {
    state = state.copyWith(errorMessage: () => message);
    return LeadActionFailed(message);
  }

  /// Puts the new viewing on the lead profile and the Viewings list.
  void _share(Viewing viewing) {
    final profile = leadProfileControllerProvider(leadId);
    if (ref.exists(profile)) {
      ref.read(profile.notifier).recordViewingBooked(viewing);
    }
    if (ref.exists(viewingsControllerProvider)) {
      ref.read(viewingsControllerProvider.notifier).addViewing(viewing);
    }
  }

  /// Signed-in user's name, as the viewing host.
  String _agentName() {
    final user = ref.read(currentUserProvider);
    if (user == null) return 'You';
    return user.name.isEmpty ? user.email : user.name;
  }
}
