import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_durations.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/clock.dart';
import '../../lead_detail/lead_activity_demo_data.dart';
import '../../lead_detail/lead_profile_demo_data.dart';
import '../../lead_detail/models/lead_insights.dart';
import '../../lead_detail/models/lead_profile.dart';
import '../../leads/leads_demo_data.dart';
import '../../leads/models/lead.dart';
import '../call_script_demo_data.dart';
import '../models/call_transcript.dart';
import '../models/live_call.dart';
import 'live_calls_controller.dart';

/// What the live call monitor (screen 12) shows at this moment.
@immutable
class LiveCallMonitor {
  /// Creates a snapshot.
  const LiveCallMonitor({
    required this.call,
    required this.lines,
    required this.qualification,
    required this.stage,
    required this.isEnded,
  });

  /// The call.
  final LiveCall call;

  /// Transcript so far, oldest first.
  final List<TranscriptLine> lines;

  /// Each question, answered once the lead has said it.
  final List<QualificationField> qualification;

  /// Current script stage.
  final CallStage stage;

  /// True once the AI has said goodbye.
  final bool isEnded;
}

/// The live call monitor for one call id. Lines appear as call time passes,
/// driven by [clockProvider]; it re-evaluates every second.
final liveCallMonitorProvider = Provider.autoDispose
    .family<AsyncValue<LiveCallMonitor>, String>((ref, callId) {
      // TODO(backend): subscribe to socket.io `call:{id}:transcript` and
      // `call:{id}:fields` instead of replaying the demo script.
      final now = ref.watch(clockProvider).value ?? DateTime.now();
      return ref.watch(liveCallsControllerProvider).whenData((snapshot) {
        final call = snapshot.active.where((c) => c.id == callId).firstOrNull;
        final lead = _demoLead(call?.leadId, now);
        if (call == null || lead == null) {
          throw ApiException(
            ApiErrorKind.notFound,
            message: 'This call has ended.',
          );
        }
        final elapsed = now.difference(call.startedAt);
        final lines = CallScriptDemoData.scriptFor(lead)
            .where((line) => line.offset <= elapsed)
            .toList();
        final captured = {
          for (final line in lines) ?line.captured?.key: line.captured,
        };
        return LiveCallMonitor(
          call: call,
          lines: lines,
          qualification: [
            for (final key in QualificationKey.values)
              captured[key] ?? QualificationField(key: key),
          ],
          stage: lines.isEmpty ? CallStage.dialing : lines.last.stage,
          isEnded: elapsed >= CallScriptDemoData.endsAt,
        );
      });
    });

/// A finished call (screens 14 and 15) by call id (`call-<leadId>-<n>`).
final callDetailProvider = FutureProvider.autoDispose
    .family<CallDetail, String>((ref, callId) async {
      // TODO(backend): GET /api/calls/{id} and GET /api/calls/{id}/transcript.
      await Future<void>.delayed(AppDurations.simulatedNetwork);
      final now = DateTime.now();
      final lead = _demoLead(leadIdOfCall(callId), now);
      final call = lead == null
          ? null
          : LeadActivityDemoData.callsFor(lead)
                .where((c) => c.id == callId)
                .firstOrNull;
      if (lead == null || call == null) {
        throw ApiException(
          ApiErrorKind.notFound,
          message: "We couldn't find this call.",
        );
      }
      final (summary, nextStep) = CallScriptDemoData.summaryFor(
        lead,
        call.outcome,
      );
      return CallDetail(
        id: call.id,
        leadId: lead.id,
        leadName: lead.name,
        startedAt: call.startedAt,
        duration: call.duration,
        outcome: call.outcome,
        summary: summary,
        nextStep: nextStep,
        qualification: call.outcome == CallOutcome.qualified
            ? LeadProfileDemoData.qualificationFor(lead)
            : [
                for (final k in QualificationKey.values)
                  QualificationField(key: k),
              ],
        score: lead.score,
        transcript: CallScriptDemoData.transcriptFor(lead, call.outcome),
      );
    }, retry: _noAutomaticRetry);

/// The lead id inside a demo call id `call-<leadId>-<n>`, or null.
String? leadIdOfCall(String callId) {
  final match = RegExp(r'^call-(.+)-\d+$').firstMatch(callId);
  return match?.group(1);
}

/// The demo lead with [leadId], or null.
Lead? _demoLead(String? leadId, DateTime now) =>
    LeadsDemoData.leads(now).where((lead) => lead.id == leadId).firstOrNull;

/// Failed loads show their error with Retry at once (no silent retries).
Duration? _noAutomaticRetry(int retryCount, Object error) => null;
