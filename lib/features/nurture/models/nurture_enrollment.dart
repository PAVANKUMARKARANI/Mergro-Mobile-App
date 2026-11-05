import 'package:flutter/foundation.dart';

/// Channel of a nurture touch.
enum NurtureChannel {
  /// Text message.
  sms('SMS'),

  /// WhatsApp message.
  whatsapp('WhatsApp'),

  /// Email.
  email('Email'),

  /// AI call.
  call('AI call');

  /// Creates a channel with its label.
  const NurtureChannel(this.label);

  /// Display label.
  final String label;
}

/// State of a lead in a journey.
enum NurtureStatus {
  /// Touches are being sent.
  active('Active'),

  /// The lead replied; waiting for the team.
  replied('Replied'),

  /// Paused by an agent.
  paused('Paused'),

  /// Stopped: opted out, booked or journey finished.
  stopped('Stopped');

  /// Creates a status with its label.
  const NurtureStatus(this.label);

  /// Display label.
  final String label;
}

/// A lead enrolled in a follow-up journey (e.g. Day 1/2/4/7).
@immutable
class NurtureEnrollment {
  /// Creates an enrollment.
  const NurtureEnrollment({
    required this.id,
    required this.leadName,
    required this.journey,
    required this.step,
    required this.totalSteps,
    required this.nextChannel,
    required this.status,
    required this.lastEvent,
    this.nextTouchAt,
  });

  /// Stable id.
  final String id;

  /// Lead's name.
  final String leadName;

  /// Journey name, e.g. "No answer · 7-day".
  final String journey;

  /// Current step, 1-based.
  final int step;

  /// Steps in the journey.
  final int totalSteps;

  /// Channel of the next touch.
  final NurtureChannel nextChannel;

  /// Journey state.
  final NurtureStatus status;

  /// Latest event, e.g. "WhatsApp read".
  final String lastEvent;

  /// When the next touch goes out; null when paused or stopped.
  final DateTime? nextTouchAt;
}
