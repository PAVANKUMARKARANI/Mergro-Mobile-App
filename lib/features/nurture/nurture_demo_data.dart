import 'models/nurture_enrollment.dart';

/// Sample enrollments shown until `GET /api/nurture/enrollments` exists.
abstract final class NurtureDemoData {
  /// Builds the sample enrollments relative to [now].
  static List<NurtureEnrollment> enrollments(DateTime now) {
    DateTime later({int days = 0, int hours = 0}) =>
        now.add(Duration(days: days, hours: hours));
    return [
      NurtureEnrollment(
        id: 'nurture-01',
        leadName: 'Karthik Rao',
        journey: 'Warm lead · 7-day',
        step: 2,
        totalSteps: 4,
        nextChannel: NurtureChannel.sms,
        status: NurtureStatus.active,
        lastEvent: 'WhatsApp read 2 h ago',
        nextTouchAt: later(hours: 3),
      ),
      NurtureEnrollment(
        id: 'nurture-02',
        leadName: 'Arnav Gupta',
        journey: 'No answer · 7-day',
        step: 1,
        totalSteps: 4,
        nextChannel: NurtureChannel.call,
        status: NurtureStatus.active,
        lastEvent: 'Missed AI call, SMS sent',
        nextTouchAt: later(hours: 1),
      ),
      NurtureEnrollment(
        id: 'nurture-03',
        leadName: 'Aditya Menon',
        journey: 'Cold lead · 30-day',
        step: 3,
        totalSteps: 6,
        nextChannel: NurtureChannel.email,
        status: NurtureStatus.replied,
        lastEvent: 'Replied: "Send me villa options"',
      ),
      NurtureEnrollment(
        id: 'nurture-04',
        leadName: 'Rahul Verma',
        journey: 'Warm lead · 7-day',
        step: 4,
        totalSteps: 4,
        nextChannel: NurtureChannel.call,
        status: NurtureStatus.active,
        lastEvent: 'Email opened',
        nextTouchAt: later(days: 1),
      ),
      NurtureEnrollment(
        id: 'nurture-05',
        leadName: 'Divya Krishnan',
        journey: 'Post-viewing · 5-day',
        step: 2,
        totalSteps: 3,
        nextChannel: NurtureChannel.whatsapp,
        status: NurtureStatus.paused,
        lastEvent: 'Paused by Neha Kapoor',
      ),
      NurtureEnrollment(
        id: 'nurture-06',
        leadName: 'Imran Khan',
        journey: 'No answer · 7-day',
        step: 2,
        totalSteps: 4,
        nextChannel: NurtureChannel.sms,
        status: NurtureStatus.stopped,
        lastEvent: 'Opted out on call · all channels stopped',
      ),
    ];
  }
}
