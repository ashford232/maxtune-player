import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mpv_audio_kit/mpv_audio_kit.dart';

class AudioVisualizer extends StatelessWidget {
  const AudioVisualizer({
    super.key,
    required this.player,
    this.height = 24,
    this.maxBars = 36,
  });

  final Player player;
  final double height;
  final int maxBars;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: height,
      width: double.infinity,
      child: StreamBuilder<FftFrame>(
        stream: player.stream.fft,
        builder: (context, snapshot) {
          final rawBands = snapshot.data?.bands;

          return CustomPaint(
            painter: SpectrumPainter(
              bands: rawBands,
              color: player.state.playing
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainer,

              maxBars: maxBars,
            ),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class SpectrumPainter extends CustomPainter {
  const SpectrumPainter({
    required this.bands,
    required this.color,
    required this.maxBars,
  });

  final List<double>? bands;
  final Color color;
  final int maxBars;

  List<double> _subsampleBands(List<double> rawBands) {
    if (rawBands.length <= maxBars) return rawBands;

    final step = rawBands.length / maxBars;
    final List<double> processed = [];

    for (int i = 0; i < maxBars; i++) {
      final start = (i * step).floor();
      final end = ((i + 1) * step).floor().clamp(0, rawBands.length);

      double sum = 0;
      for (int j = start; j < end; j++) {
        sum += rawBands[j];
      }
      processed.add(sum / (end - start));
    }
    return processed;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final values = bands != null && bands!.isNotEmpty
        ? _subsampleBands(bands!)
        : List.filled(maxBars, 0.05); // Subtle idle placeholder height

    const gap = 3.0;
    final count = values.length;
    final barWidth = (size.width - (count - 1) * gap) / count;

    final paint = Paint()
      ..color = bands == null || bands!.isEmpty
          ? color.withValues(alpha: 0.2) // Faint color when idle
          : color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    for (var i = 0; i < count; i++) {
      final value = values[i].clamp(0.0, 1.0);
      final barHeight = math.max(3.0, value * size.height);

      // Dynamically clamp radius to prevent visual clipping on thin bars
      final cornerRadius = math.min(barWidth / 2, 3.0);

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          i * (barWidth + gap),
          size.height - barHeight,
          barWidth,
          barHeight,
        ),
        Radius.circular(cornerRadius),
      );

      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SpectrumPainter oldDelegate) {
    return oldDelegate.bands != bands ||
        oldDelegate.color != color ||
        oldDelegate.maxBars != maxBars;
  }
}


class SpectrumMountain extends StatelessWidget {
  const SpectrumMountain({
    super.key,
    required this.player,
    this.height = 100,
  });

  final Player player;
  final double height;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: StreamBuilder<FftFrame>(
        stream: player.stream.fft,
        builder: (context, snapshot) {
          return CustomPaint(
            painter: MountainPainter(
              bands: snapshot.data?.bands,
              color: color,
            ),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class MountainPainter extends CustomPainter {
  const MountainPainter({
    required this.bands,
    required this.color,
  });

  final List<double>? bands;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final values = bands;

    if (values == null || values.isEmpty) return;

    final path = Path();
    final baseline = size.height;
    final step = size.width / (values.length - 1);

    path.moveTo(0, baseline);

    for (int i = 0; i < values.length; i++) {
      final x = i * step;
      final amplitude = values[i].clamp(0.0, 1.0);
      final y = baseline - (amplitude * size.height * 0.9);

      if (i == 0) {
        path.lineTo(x, y);
      } else {
        final previousX = (i - 1) * step;
        final previousY =
            baseline - (values[i - 1].clamp(0.0, 1.0) * size.height * 0.9);

        final controlX = (previousX + x) / 2;

        path.quadraticBezierTo(
          controlX,
          previousY,
          controlX,
          (previousY + y) / 2,
        );

        path.quadraticBezierTo(
          controlX,
          y,
          x,
          y,
        );
      }
    }

    path.lineTo(size.width, baseline);
    path.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.65),
          color.withValues(alpha: 0.05),
        ],
      ).createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    canvas.drawPath(path, fillPaint);

    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final outline = Path();

    for (int i = 0; i < values.length; i++) {
      final x = i * step;
      final y = baseline -
          (values[i].clamp(0.0, 1.0) * size.height * 0.9);

      if (i == 0) {
        outline.moveTo(x, y);
      } else {
        outline.lineTo(x, y);
      }
    }

    canvas.drawPath(outline, linePaint);
  }

  @override
  bool shouldRepaint(covariant MountainPainter oldDelegate) {
    return oldDelegate.bands != bands || oldDelegate.color != color;
  }
}