import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ControlsView extends ConsumerStatefulWidget {
  const ControlsView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ControlsViewState();
}

class _ControlsViewState extends ConsumerState<ControlsView> {
  double _volumeValue = 0.8;
  bool _isMuted = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 600;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12),
          child: isSmall
              ? _buildCompactPlayer(theme)
              : _buildExpandedPlayer(theme),
        );
      },
    );
  }

  Widget _buildCompactPlayer(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              onPressed: () {},
              child: const Icon(HugeIconsStroke.musicNote01, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Skeletonizer(
                    textBoneBorderRadius: TextBoneBorderRadius(
                      .all(Radius.circular(2)),
                    ),
                    child: Text(
                      '[Daddy Yo]_ D NAT X Y.A.D',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Skeletonizer(
                    textBoneBorderRadius: TextBoneBorderRadius(
                      .all(Radius.circular(2)),
                    ),
                    child: Text('D NAT', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Centralized playback controls for compact view
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(HugeIconsSolid.previous, size: 20),
            ),
            const SizedBox(width: 10),
            IconButton(
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.all(10),
              ),
              onPressed: () {},
              icon: const Icon(HugeIconsSolid.play, size: 22),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: () {},
              icon: const Icon(HugeIconsSolid.next, size: 20),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExpandedPlayer(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. Album / File Art Indicator
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 26),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          onPressed: () {},
          child: const Icon(HugeIconsStroke.musicNote01),
        ),
        const SizedBox(width: 16),

        // 2. Track Info & Timeline Section
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Skeletonizer(
                textBoneBorderRadius: TextBoneBorderRadius(
                  .all(Radius.circular(2)),
                ),
                child: const Text(
                  '[Daddy Yo]_ D NAT X Y.A.D • D NAT',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text('0:00:00', style: TextStyle(fontSize: 10)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 20,
                      child: Slider(value: 0, onChanged: (value) {}),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('0:00:00', style: TextStyle(fontSize: 10)),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 20),

        // 3. Centralized Playback Controls (Prev, Play/Pause, Next)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(HugeIconsSolid.previous, size: 20),
              tooltip: 'Previous',
            ),
            const SizedBox(width: 4),
            IconButton(
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.all(10),
                shape: const CircleBorder(),
              ),
              onPressed: () {},
              icon: const Icon(HugeIconsSolid.play, size: 22),
              tooltip: 'Play',
            ),
            const SizedBox(width: 4),
            IconButton(
              onPressed: () {},
              icon: const Icon(HugeIconsSolid.next, size: 20),
              tooltip: 'Next',
            ),
          ],
        ),

        const SizedBox(width: 20),

        // 4. Volume Control Section
        SizedBox(
          width: 150,
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _isMuted = !_isMuted;
                  });
                },
                icon: Icon(
                  _isMuted
                      ? HugeIconsSolid.volumeMute01
                      : HugeIconsSolid.volumeHigh,
                  size: 20,
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: 20,
                  child: Slider(
                    value: _isMuted ? 0 : _volumeValue,
                    onChanged: (value) {
                      setState(() {
                        _volumeValue = value;
                        if (_isMuted) _isMuted = false;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
