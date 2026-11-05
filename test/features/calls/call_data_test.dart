import 'package:flutter_test/flutter_test.dart';
import 'package:mergro_ai_voice_assistant/core/network/api_exception.dart';
import 'package:mergro_ai_voice_assistant/core/utils/pii_mask.dart';
import 'package:mergro_ai_voice_assistant/features/calls/call_script_demo_data.dart';
import 'package:mergro_ai_voice_assistant/features/calls/controllers/call_providers.dart';
import 'package:mergro_ai_voice_assistant/features/calls/controllers/live_calls_controller.dart';
import 'package:mergro_ai_voice_assistant/features/calls/models/call_transcript.dart';
import 'package:mergro_ai_voice_assistant/features/calls/models/live_call.dart';
import 'package:mergro_ai_voice_assistant/features/lead_detail/models/lead_profile.dart';
import 'package:mergro_ai_voice_assistant/features/leads/leads_demo_data.dart';

import '../../helpers/fakes.dart';

void main() {
  group('PiiMask', () {
    test('masks emails and phone numbers, keeps the rest', () {
      expect(
        PiiMask.mask('Call +91 98450 12210 or mail ananya.iyer@gmail.com now'),
        'Call •••• 10 or mail a•••@gmail.com now',
      );
      expect(PiiMask.mask('Around ₹85 L – 1 Cr.'), 'Around ₹85 L – 1 Cr.');
    });
  });

  group('Call script', () {
    final lead = LeadsDemoData.leads(DateTime.now()).first;

    test('captures all five answers and ends after the last line', () {
      final script = CallScriptDemoData.scriptFor(lead);
      expect(script.where((line) => line.captured != null), hasLength(5));
      expect(script.last.offset < CallScriptDemoData.endsAt, isTrue);
      expect(script.first.speaker, Speaker.ai);
      expect(script.first.text, contains('AI assistant'), reason: 'discloses');
    });

    test('transcript follows the outcome', () {
      expect(
        CallScriptDemoData.transcriptFor(lead, CallOutcome.noAnswer),
        isEmpty,
      );
      final optOut = CallScriptDemoData.transcriptFor(
        lead,
        CallOutcome.optedOut,
      );
      expect(optOut.last.text, contains("don't call"));
    });

    test('call ids carry the lead id', () {
      expect(leadIdOfCall('call-lead-02-1'), 'lead-02');
      expect(leadIdOfCall('nonsense'), isNull);
    });
  });

  group('Live call monitor', () {
    test(
      'shows the lines said so far, the stage and captured answers',
      () async {
        final container = fakeContainer();
        container.listen(liveCallMonitorProvider('call-01'), (_, _) {});
        await container.read(liveCallsControllerProvider.future);

        final monitor = container
            .read(liveCallMonitorProvider('call-01'))
            .value!;
        // Priyanka's call started 240 s ago: past the questions, into booking.
        expect(monitor.stage, CallStage.booking);
        expect(
          monitor.qualification.every((field) => field.isAnswered),
          isTrue,
        );
        expect(monitor.isEnded, isFalse);

        final fresh = container.read(liveCallMonitorProvider('call-03')).value!;
        expect(fresh.stage, CallStage.disclosure);
        // Deepak's call started 12 s ago: the disclosure and his reply.
        expect(fresh.lines, hasLength(2));
        expect(fresh.qualification.any((field) => field.isAnswered), isFalse);
      },
    );

    test('a call that is not live is reported as ended', () async {
      final container = fakeContainer();
      container.listen(liveCallMonitorProvider('call-99'), (_, _) {});
      await container.read(liveCallsControllerProvider.future);
      final value = container.read(liveCallMonitorProvider('call-99'));
      expect(value.error, isA<ApiException>());
    });
  });

  group('Call detail', () {
    Future<CallDetail> load(String callId) {
      final container = fakeContainer();
      container.listen(callDetailProvider(callId), (_, _) {});
      return container.read(callDetailProvider(callId).future);
    }

    test('a qualified call has the full transcript and answers', () async {
      final detail = await load('call-lead-02-1');
      expect(detail.outcome, CallOutcome.qualified);
      expect(detail.transcript.length, greaterThan(10));
      expect(detail.qualification.every((field) => field.isAnswered), isTrue);
      expect(detail.summary, contains('Koramangala'));
    });

    test('an unanswered call has no transcript', () async {
      final detail = await load('call-lead-07-1');
      expect(detail.outcome, CallOutcome.noAnswer);
      expect(detail.transcript, isEmpty);
      expect(detail.duration, Duration.zero);
    });

    test('an unknown call is not found', () async {
      await expectLater(
        load('call-lead-99-1'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.kind,
            'kind',
            ApiErrorKind.notFound,
          ),
        ),
      );
    });
  });
}
