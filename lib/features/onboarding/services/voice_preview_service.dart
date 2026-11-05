import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../core/utils/app_logger.dart';

/// Speaks a voice preview. Abstracted so tests can fake it and the device
/// text-to-speech can later be replaced by real AI voice samples.
abstract interface class VoicePreviewService {
  /// Speaks [text] and completes when it finishes or is stopped.
  /// Returns false if the device can't play speech.
  Future<bool> speak(
    String text, {
    required String locale,
    required double pitch,
    required double speechRate,
  });

  /// Stops any speech in progress.
  Future<void> stop();
}

/// The app's voice preview implementation.
// TODO(backend): replace device TTS with the real voice sample —
// GET /voices/{id}/sample (audio), played with an audio player.
final voicePreviewServiceProvider = Provider<VoicePreviewService>(
  (ref) => DeviceTtsVoicePreviewService(),
);

/// Voice preview using the phone's built-in text-to-speech voices.
class DeviceTtsVoicePreviewService implements VoicePreviewService {
  final FlutterTts _tts = FlutterTts();
  bool _isConfigured = false;

  /// One-time setup: await completion, and on iOS use the playback audio
  /// category so the preview is audible even with the Silent switch on.
  Future<void> _configure() async {
    if (_isConfigured) return;
    await _tts.awaitSpeakCompletion(true);
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _tts.setSharedInstance(true);
      await _tts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback, [
        IosTextToSpeechAudioCategoryOptions.duckOthers,
      ]);
    }
    _isConfigured = true;
  }

  /// Configures pitch, rate and accent, then speaks [text].
  @override
  Future<bool> speak(
    String text, {
    required String locale,
    required double pitch,
    required double speechRate,
  }) async {
    try {
      await _configure();
      await _tts.setLanguage(locale);
      await _tts.setPitch(pitch);
      await _tts.setSpeechRate(speechRate);
      await _tts.speak(text);
      return true;
    } on PlatformException catch (error) {
      AppLogger.warning('Voice preview failed to play', error);
      return false;
    } on MissingPluginException catch (error) {
      AppLogger.warning('Text-to-speech is unavailable', error);
      return false;
    }
  }

  /// Stops speech; failures are logged and ignored.
  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } on PlatformException catch (error) {
      AppLogger.warning('Voice preview failed to stop', error);
    } on MissingPluginException catch (error) {
      AppLogger.warning('Text-to-speech is unavailable', error);
    }
  }
}
