import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:lite_router/lite_router.dart';
import 'package:maxtune_player/app/services/app_providers.dart';
import 'package:maxtune_player/app/views/controls.dart';
import 'package:maxtune_player/app/widgets/waveform_seekbar.dart';
import 'package:maxtune_player/core/db/services/database_provider.dart';

class PlayerView extends ConsumerStatefulWidget {
  const PlayerView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PlayerViewState();
}

class _PlayerViewState extends ConsumerState<PlayerView> {
  @override
  Widget build(BuildContext context) {
    final musicNotifier = ref.watch(musicServiceProvider.notifier);
    final musicService = ref.watch(musicServiceProvider);
    final theme = Theme.of(context);
    final track = musicService.current == null
        ? null
        : File(musicService.current!.path);
    final fileExists = track?.existsSync() ?? false;

    if (!fileExists) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        musicNotifier.removeMissingFiles();
        if (musicNotifier.audioPlayer.state.playing) {
          musicNotifier.togglePlayPause();
        }
      });
    }
    final songOperation = ref.read(songsOperationProvider);
    final songAsync = ref.watch(watchSongProvider(track?.path ?? ""));
    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainer,
      appBar: AppBar(
        actions: [
          songAsync.when(
            data: (s) {
              if (s == null) {
                return SizedBox.shrink();
              }
              return IconButton(
                onPressed: () async {
                  if (s.isFavorite == true) {
                    songOperation.removeFavorite(s.path);
                  } else {
                    songOperation.addFavorite(s.path);
                  }
                },
                icon: Icon(
                  s.isFavorite == true
                      ? HugeIconsSolid.favourite
                      : HugeIconsStroke.favourite,
                  size: 20,
                  color: s.isFavorite == true
                      ? theme.colorScheme.primary
                      : null,
                ),
              );
            },
            error: (err, st) => SizedBox.shrink(),
            loading: () => SizedBox.shrink(),
          ),
          const SizedBox(width: 12),
        ],
        backgroundColor: theme.colorScheme.surfaceContainer,

        leading: IconButton(
          onPressed: () {
            context.back();
          },
          icon: Icon(HugeIconsStroke.arrowLeft02),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 600;
          return !fileExists
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(children: []),
                )
              : Column(
                  crossAxisAlignment: .start,
                  mainAxisAlignment: .end,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: .center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 2.0,
                            ),

                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: WaveformSeekBar(
                                player: musicNotifier.audioPlayer,
                                showTime: false,
                                height: !isSmall ? 145 : 120,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Divider(height: 1),
                    ControlsView(isPlayer: true),
                  ],
                );
        },
      ),
    );
  }
}
