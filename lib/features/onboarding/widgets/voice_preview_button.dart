import 'dart:math' as math;

import '../../../shared/ui.dart';

/// Play / stop button that shows a moving waveform while [isPlaying].
/// Takes values and a callback only; playback lives in the controller.
class VoicePreviewButton extends StatefulWidget {
  /// Creates the button for the voice named [voiceLabel].
  const VoicePreviewButton({
    super.key,
    required this.voiceLabel,
    required this.isPlaying,
    required this.onPressed,
  });

  /// Voice name, used for the tooltip / semantics label.
  final String voiceLabel;

  /// Whether this voice is speaking right now.
  final bool isPlaying;

  /// Plays or stops the preview.
  final VoidCallback onPressed;

  /// Creates the state owning the waveform animation.
  @override
  State<VoicePreviewButton> createState() => _VoicePreviewButtonState();
}

/// Owns the repeating waveform animation.
class _VoicePreviewButtonState extends State<VoicePreviewButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.voiceWaveCycle,
  );

  /// Starts the waveform if the button is created while already playing.
  @override
  void initState() {
    super.initState();
    if (widget.isPlaying) _controller.repeat();
  }

  /// Starts or stops the waveform when playback state changes.
  @override
  void didUpdateWidget(VoicePreviewButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying == oldWidget.isPlaying) return;
    widget.isPlaying ? _controller.repeat() : _controller.reset();
  }

  /// Releases the controller.
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Builds the button and, while playing, the waveform.
  @override
  Widget build(BuildContext context) {
    final isPlaying = widget.isPlaying;
    final disableMotion = MediaQuery.disableAnimationsOf(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isPlaying)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => CustomPaint(
              size: const Size(AppSizes.cardIconTile, AppSizes.iconLg),
              painter: _WaveformPainter(
                // Reduced motion: a static waveform while speaking.
                progress: disableMotion ? 0.25 : _controller.value,
                color: context.palette.accent,
              ),
            ),
          ),
        IconButton(
          onPressed: widget.onPressed,
          tooltip: isPlaying
              ? 'Stop ${widget.voiceLabel} preview'
              : 'Play ${widget.voiceLabel} preview',
          icon: Icon(
            isPlaying ? LucideIcons.square : LucideIcons.play,
            size: AppSizes.iconMd,
          ),
        ),
      ],
    );
  }
}

/// Five rounded bars whose heights oscillate with [progress].
class _WaveformPainter extends CustomPainter {
  /// Creates the painter.
  const _WaveformPainter({required this.progress, required this.color});

  /// Animation progress, 0–1.
  final double progress;

  /// Bar colour.
  final Color color;

  static const int _barCount = 5;
  static const int _cycles = 1;
  static const double _minFactor = 0.25;

  /// Draws the bars centred vertically.
  @override
  void paint(Canvas canvas, Size size) {
    final slot = size.width / _barCount;
    final barWidth = slot / 2;
    final paint = Paint()..color = color;
    for (var index = 0; index < _barCount; index++) {
      final wave = math.sin(2 * math.pi * (_cycles * progress) + index * 1.1);
      final factor = _minFactor + (1 - _minFactor) * (0.5 + 0.5 * wave);
      final height = size.height * factor;
      final rect = Rect.fromLTWH(
        index * slot + (slot - barWidth) / 2,
        (size.height - height) / 2,
        barWidth,
        height,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(barWidth / 2)),
        paint,
      );
    }
  }

  /// Repaints on every tick.
  @override
  bool shouldRepaint(_WaveformPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
