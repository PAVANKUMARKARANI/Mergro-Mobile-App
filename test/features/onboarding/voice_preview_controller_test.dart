import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/controllers/voice_preview_controller.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/models/onboarding_options.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/services/voice_preview_service.dart';

/// Records calls; speech "plays" until [finish] or stop() is called.
class _FakeVoicePreviewService implements VoicePreviewService {
  final List<String> calls = [];
  Completer<void>? _speaking;
  bool isAvailable = true;

  /// Ends the current utterance as if it finished naturally.
  void finish() => _speaking?.complete();

  @override
  Future<bool> speak(
    String text, {
    required String locale,
    required double pitch,
    required double speechRate,
  }) async {
    calls.add('speak $locale $pitch');
    if (!isAvailable) return false;
    _speaking = Completer<void>();
    await _speaking?.future;
    return true;
  }

  @override
  Future<void> stop() async {
    calls.add('stop');
    final speaking = _speaking;
    if (speaking != null && !speaking.isCompleted) speaking.complete();
  }
}

void main() {
  late _FakeVoicePreviewService service;
  late ProviderContainer container;

  setUp(() {
    service = _FakeVoicePreviewService();
    container = ProviderContainer.test(
      overrides: [voicePreviewServiceProvider.overrideWithValue(service)],
    );
    container.listen(voicePreviewControllerProvider, (_, _) {});
  });

  VoicePreviewController controller() =>
      container.read(voicePreviewControllerProvider.notifier);

  test('plays with the voice pitch and country accent, then clears', () async {
    final playing = controller().togglePreview(
      AgentVoice.calmMale,
      'Hi',
      Country.unitedStates,
    );
    await Future<void>.delayed(Duration.zero);
    expect(container.read(voicePreviewControllerProvider), AgentVoice.calmMale);
    expect(service.calls.last, 'speak en-US ${AgentVoice.calmMale.pitch}');

    service.finish();
    expect(await playing, isTrue);
    expect(container.read(voicePreviewControllerProvider), isNull);
  });

  test('tapping another voice switches; tapping again stops', () async {
    unawaited(
      controller().togglePreview(AgentVoice.warmFemale, 'Hi', Country.india),
    );
    await Future<void>.delayed(Duration.zero);
    unawaited(
      controller().togglePreview(AgentVoice.brightFemale, 'Hi', Country.india),
    );
    await Future<void>.delayed(Duration.zero);
    expect(
      container.read(voicePreviewControllerProvider),
      AgentVoice.brightFemale,
    );

    await controller().togglePreview(
      AgentVoice.brightFemale,
      'Hi',
      Country.india,
    );
    expect(container.read(voicePreviewControllerProvider), isNull);
    expect(service.calls.last, 'stop');
  });

  test('reports when speech is unavailable', () async {
    service.isAvailable = false;
    expect(
      await controller().togglePreview(
        AgentVoice.calmMale,
        'Hi',
        Country.india,
      ),
      isFalse,
    );
    expect(container.read(voicePreviewControllerProvider), isNull);
  });
}
