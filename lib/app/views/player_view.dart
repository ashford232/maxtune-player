import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:lite_router/lite_router.dart';
import 'package:maxtune_player/app/services/app_providers.dart';
import 'package:maxtune_player/app/views/controls.dart';
import 'package:maxtune_player/app/widgets/audio_visualizer.dart';
import 'package:maxtune_player/app/widgets/waveform_seekbar.dart';

class PlayerView extends ConsumerStatefulWidget {
  const PlayerView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PlayerViewState();
}

class _PlayerViewState extends ConsumerState<PlayerView> {
  @override
  Widget build(BuildContext context) {
    final musicNotifier = ref.watch(musicServiceProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.back();
          },
          icon: Icon(HugeIconsStroke.arrowLeft02),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 750;
          final isSmall = constraints.maxWidth < 600;
          return Column(
            crossAxisAlignment: .start,
            mainAxisAlignment: .end,
            children: [
              if (!isSmall)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isSmall
                          ? 350
                          : isCompact
                          ? 500
                          : 700,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 12,
                      ),
                      child: AudioVisualizer(
                        height: 118,
                        player: musicNotifier.audioPlayer,
                      ),
                    ),
                  ),
                ),
              if (isCompact && isSmall)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),

                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: WaveformSeekBar(
                      player: musicNotifier.audioPlayer,
                      showTime: false,
                      height: 132,
                    ),
                  ),
                ),
              ControlsView(isPlayer: true),
            ],
          );
        },
      ),
    );
  }
}
