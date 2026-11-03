import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:lite_router/lite_router.dart';
import 'package:maxtune_player/app/services/app_providers.dart';
import 'package:maxtune_player/app/services/music_service.dart';
import 'package:maxtune_player/app/views/controls.dart';
import 'package:maxtune_player/app/views/player_view.dart';
import 'package:maxtune_player/app/widgets/audio_visualizer.dart';
import 'package:path/path.dart' as p;

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  MusicState get musicService => ref.watch(musicServiceProvider);
  MusicService get musicNotifier => ref.watch(musicServiceProvider.notifier);

  @override
  void dispose() {
    if (musicNotifier.audioPlayer.state.playing) {
      musicNotifier.togglePlayPause();
    }
    musicNotifier.disposePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final musicService = ref.watch(musicServiceProvider);
    final musicNotifier = ref.watch(musicServiceProvider.notifier);
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 750;
          final isSmall = constraints.maxWidth < 600;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child:
                  musicService.library.isEmpty && musicService.current == null
                  ? Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            HugeIconsSolid.folderMusic,
                            size: isSmall
                                ? 0
                                : isCompact
                                ? 90
                                : 120,
                          ),
                          const SizedBox(width: 20),

                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 350),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'A better way to enjoy your music.',
                                  style: TextStyle(
                                    fontSize: isCompact ? 20 : 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Flexible(
                                  child: Text(
                                    'Bring your local music collection together, discover your favorite tracks, and enjoy effortless playback.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                ElevatedButton(
                                  onPressed: () async {
                                    final res = await openFiles();
                                    musicNotifier.changeState(
                                      music: musicService.copyWith(
                                        library: res,
                                        current: res.isNotEmpty
                                            ? res.first
                                            : null,
                                      ),
                                    );

                                    if (res.isNotEmpty) {
                                      musicNotifier.playTrack(res.first);
                                    }
                                  },
                                  child: const Text('Open file(s)'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : !isCompact
                  ? ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 900),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                        ),
                        itemCount: musicService.library.length,
                        itemBuilder: (context, index) {
                          final currentTrack = File(musicService.current!.path);
                          final track = File(musicService.library[index].path);
                          final metadata = readMetadata(track, getImage: true);
                          final fileName = p.basename(track.path);
                          final isCurrentPlaying =
                              track.path == currentTrack.path;
                          if (!track.existsSync()) {
                            return SizedBox.shrink();
                          }
                          return InkWell(
                            borderRadius: .circular(2),

                            onTap: () async {
                              if (isCurrentPlaying) {
                                context.push(PlayerView());
                                return;
                              }
                              await musicNotifier.playTrack(XFile(track.path));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: .circular(2),

                                color: isCurrentPlaying
                                    ? theme.colorScheme.onSurface.withValues(
                                        alpha: 0.1,
                                      )
                                    : null,
                              ),
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: .start,
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      child: metadata.pictures.isNotEmpty
                                          ? Image.memory(
                                              metadata.pictures.first.bytes,
                                              fit: .cover,
                                              cacheHeight: 100,
                                              cacheWidth: 100,
                                              gaplessPlayback: true,
                                            )
                                          : Container(
                                              decoration: BoxDecoration(
                                                borderRadius: .circular(2),
                                                color: theme
                                                    .colorScheme
                                                    .onSurface
                                                    .withValues(alpha: 0.1),
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  HugeIconsStroke.musicNote03,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                  Text(
                                    metadata.title ?? fileName,
                                    maxLines: 1,
                                    overflow: .ellipsis,
                                    style: TextStyle(
                                      fontSize: isSmall
                                          ? 12
                                          : isCompact
                                          ? 14
                                          : 17,
                                    ),
                                  ),

                                  if (metadata.duration != null)
                                    Text(
                                      formatDuration(metadata.duration!),
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  if (isCurrentPlaying)
                                    SpectrumMountain(
                                      height: 10,
                                      player: musicNotifier.audioPlayer,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : ListView.separated(
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 2),
                      itemCount: musicService.library.length,
                      itemBuilder: (context, index) {
                        final currentTrack = File(musicService.current!.path);
                        final track = File(musicService.library[index].path);
                        if (!track.existsSync()) {
                          return SizedBox.shrink();
                        }
                        final metadata = readMetadata(track, getImage: true);
                        final fileName = p.basename(track.path);
                        final isCurrentPlaying =
                            track.path == currentTrack.path;
                        final double size = isSmall
                            ? 30
                            : isCompact
                            ? 50
                            : 70;
                        return InkWell(
                          borderRadius: .circular(2),

                          onTap: () async {
                            if (isCurrentPlaying) {
                              context.push(PlayerView());
                              return;
                            }
                            await musicNotifier.playTrack(XFile(track.path));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: .circular(2),

                              color: isCurrentPlaying
                                  ? theme.colorScheme.onSurface.withValues(
                                      alpha: 0.1,
                                    )
                                  : null,
                            ),
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: .start,
                              children: [
                                Row(
                                  crossAxisAlignment: .start,
                                  children: [
                                    SizedBox(
                                      width: size,
                                      height: size,
                                      child: metadata.pictures.isNotEmpty
                                          ? Image.memory(
                                              metadata.pictures.first.bytes,
                                              fit: .cover,
                                              cacheHeight: 100,
                                              cacheWidth: 100,
                                              width: size,
                                              height: size,
                                              gaplessPlayback: true,
                                            )
                                          : Container(
                                              decoration: BoxDecoration(
                                                borderRadius: .circular(2),
                                                color: theme
                                                    .colorScheme
                                                    .onSurface
                                                    .withValues(alpha: 0.1),
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  HugeIconsStroke.musicNote03,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: .start,
                                        children: [
                                          Text(
                                            metadata.title ?? fileName,
                                            maxLines: 1,
                                            overflow: .ellipsis,
                                            style: TextStyle(
                                              fontSize: isSmall
                                                  ? 12
                                                  : isCompact
                                                  ? 14
                                                  : 17,
                                            ),
                                          ),
                                          if (!isSmall)
                                            Text(
                                              metadata.artist ?? "Unknown",
                                              style: TextStyle(fontSize: 12),
                                            ),

                                          if (metadata.duration != null)
                                            Text(
                                              formatDuration(
                                                metadata.duration!,
                                              ),
                                              style: TextStyle(fontSize: 10),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (isCurrentPlaying)
                                  SpectrumMountain(
                                    height: 10,
                                    player: musicNotifier.audioPlayer,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          );
        },
      ),
    );
  }
}
