import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mpv_audio_kit/mpv_audio_kit.dart';

class WaveformSeekBar extends StatefulWidget {
  const WaveformSeekBar({
    super.key,
    required this.player,
    this.height = 48,
    this.showTime = true,
  });

  final Player player;
  final double height;
  final bool showTime;

  @override
  State<WaveformSeekBar> createState() => _WaveformSeekBarState();
}

class _WaveformSeekBarState extends State<WaveformSeekBar> {
  double? _dragFraction;

  String _formatTime(Duration duration) {
    final seconds = duration.inSeconds.clamp(0, 999999);
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    }

    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  double _fractionForPosition(Duration position, WaveformData waveform) {
    if (waveform.duration <= Duration.zero) return 0;

    final offset = position - waveform.start;

    return (offset.inMicroseconds / waveform.duration.inMicroseconds).clamp(
      0.0,
      1.0,
    );
  }

  Duration _positionForFraction(double fraction, WaveformData waveform) {
    final offset = Duration(
      microseconds: (waveform.duration.inMicroseconds * fraction).round(),
    );

    return waveform.start + offset;
  }

  void _seek(double fraction, WaveformData waveform) {
    widget.player.seek(_positionForFraction(fraction, waveform));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final playedColor = theme.colorScheme.primary;

    final unplayedColor = theme.colorScheme.onSurface.withValues(alpha: 0.16);

    final playheadColor = theme.colorScheme.onSurface;

    return StreamBuilder<WaveformData?>(
      stream: widget.player.stream.waveform,
      builder: (context, waveformSnapshot) {
        final waveform = waveformSnapshot.data;

        return StreamBuilder<Duration>(
          stream: widget.player.stream.position,
          builder: (context, positionSnapshot) {
            final position =
                positionSnapshot.data ?? widget.player.state.position;

            final progress = waveform == null
                ? 0.0
                : _dragFraction ?? _fractionForPosition(position, waveform);

            final displayPosition = waveform != null && _dragFraction != null
                ? _positionForFraction(_dragFraction!, waveform)
                : position;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;

                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,

                      // Click to seek.
                      onTapDown: waveform == null || width <= 0
                          ? null
                          : (details) {
                              final fraction =
                                  (details.localPosition.dx / width).clamp(
                                    0.0,
                                    1.0,
                                  );

                              setState(() {
                                _dragFraction = null;
                              });

                              _seek(fraction, waveform);
                            },

                      // Begin dragging.
                      onHorizontalDragStart: waveform == null
                          ? null
                          : (_) {
                              setState(() {
                                _dragFraction = progress;
                              });
                            },

                      // Update position while dragging.
                      onHorizontalDragUpdate: waveform == null || width <= 0
                          ? null
                          : (details) {
                              setState(() {
                                _dragFraction =
                                    (details.localPosition.dx / width).clamp(
                                      0.0,
                                      1.0,
                                    );
                              });
                            },

                      // Seek when dragging ends.
                      onHorizontalDragEnd: waveform == null
                          ? null
                          : (_) {
                              final fraction = _dragFraction;

                              setState(() {
                                _dragFraction = null;
                              });

                              if (fraction != null) {
                                _seek(fraction, waveform);
                              }
                            },

                      child: SizedBox(
                        height: widget.height,
                        width: double.infinity,
                        child: CustomPaint(
                          painter: WaveformPainter(
                            waveform: waveform,
                            progress: progress,
                            playedColor: playedColor,
                            unplayedColor: unplayedColor,
                            playheadColor: playheadColor,
                          ),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    );
                  },
                ),

                if (widget.showTime) ...[
                  const SizedBox(height: 7),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatTime(displayPosition),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        _formatTime(widget.player.state.duration),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }
}

class WaveformPainter extends CustomPainter {
  const WaveformPainter({
    required this.waveform,
    required this.progress,
    required this.playedColor,
    required this.unplayedColor,
    required this.playheadColor,
  });

  final WaveformData? waveform;
  final double progress;
  final Color playedColor;
  final Color unplayedColor;
  final Color playheadColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.height / 2;
    final halfHeight = size.height * 0.44;

    final data = waveform;

    if (data == null || data.bins == 0) {
      final paint = Paint()
        ..color = unplayedColor
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(Offset(0, center), Offset(size.width, center), paint);

      return;
    }

    final playedPaint = Paint()
      ..color = playedColor
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final unplayedPaint = Paint()
      ..color = unplayedColor
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    // Draw approximately one waveform sample per horizontal pixel.
    final pixelCount = size.width.ceil().clamp(1, 10000);
    final binsPerPixel = data.bins / pixelCount;

    for (int x = 0; x < pixelCount; x++) {
      final start = (x * binsPerPixel).floor();

      final end = math
          .max(start + 1, ((x + 1) * binsPerPixel).ceil())
          .clamp(0, data.bins);

      double minValue = 0;
      double maxValue = 0;
      bool hasData = false;

      for (int i = start; i < end; i++) {
        if (data.filled[i] == 0) continue;

        minValue = math.min(minValue, data.min[i]);
        maxValue = math.max(maxValue, data.max[i]);
        hasData = true;
      }

      final dx = (x + 0.5) * size.width / pixelCount;

      final amplitude = hasData ? 1.0 : 0.035;

      final top = hasData
          ? center - maxValue * halfHeight
          : center - halfHeight * amplitude;

      final bottom = hasData
          ? center - minValue * halfHeight
          : center + halfHeight * amplitude;

      final paint = (x / pixelCount) < progress ? playedPaint : unplayedPaint;

      canvas.drawLine(Offset(dx, top), Offset(dx, bottom), paint);
    }

    // Exact playback position.
    final indicatorX = (size.width * progress).clamp(0.0, size.width);

    final playheadPaint = Paint()
      ..color = playheadColor
      ..isAntiAlias = true;

    // Vertical indicator.
    canvas.drawLine(
      Offset(indicatorX, 0),
      Offset(indicatorX, size.height),
      playheadPaint
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return oldDelegate.waveform != waveform ||
        oldDelegate.progress != progress ||
        oldDelegate.playedColor != playedColor ||
        oldDelegate.unplayedColor != unplayedColor ||
        oldDelegate.playheadColor != playheadColor;
  }
}
