import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/onboarding_options.dart';
import '../services/voice_preview_service.dart';

/// Which voice is speaking its preview right now (null = silent). Disposed,
/// and speech stopped, when the AI agent step leaves the screen.
final voicePreviewControllerProvider =
    NotifierProvider.autoDispose<VoicePreviewController, AgentVoice?>(
      VoicePreviewController.new,
    );

/// Plays and stops voice previews, one voice at a time.
class VoicePreviewController extends Notifier<AgentVoice?> {
  /// Whether a preview was started; avoids a needless stop on dispose.
  bool _hasPlayed = false;

  /// Starts silent and stops any speech when disposed.
  @override
  AgentVoice? build() {
    // Captured here because Riverpod forbids using ref inside onDispose.
    final service = ref.watch(voicePreviewServiceProvider);
    ref.onDispose(() {
      if (_hasPlayed) service.stop();
    });
    return null;
  }

  /// Speaks [greeting] in [voice] with [country]'s accent. Tapping the
  /// playing voice again stops it. Returns false if speech is unavailable.
  Future<bool> togglePreview(
    AgentVoice voice,
    String greeting,
    Country country,
  ) async {
    final service = ref.read(voicePreviewServiceProvider);
    if (state == voice) {
      await stop();
      return true;
    }
    await service.stop();
    _hasPlayed = true;
    state = voice;
    final isPlayed = await service.speak(
      greeting,
      locale: country.speechLocale,
      pitch: voice.pitch,
      speechRate: voice.speechRate,
    );
    // Only clear if no other voice started meanwhile.
    if (ref.mounted && state == voice) state = null;
    return isPlayed;
  }

  /// Stops the current preview.
  Future<void> stop() async {
    state = null;
    await ref.read(voicePreviewServiceProvider).stop();
  }
}
