import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:lite_router/lite_router.dart';
import 'package:maxtune_player/app/services/app_providers.dart';
import 'package:maxtune_player/app/services/music_service.dart';
import 'package:maxtune_player/app/views/controls.dart';
import 'package:maxtune_player/app/views/player_view.dart';
import 'package:maxtune_player/app/widgets/audio_visualizer.dart';
import 'package:maxtune_player/core/db/app_database.dart';
import 'package:maxtune_player/core/db/operations/song_operations.dart';
import 'package:maxtune_player/core/db/services/database_provider.dart';
import 'package:maxtune_player/features/library/services/library_provider.dart';

class AllSongs extends ConsumerStatefulWidget {
  const AllSongs({super.key});

  @override
  ConsumerState<AllSongs> createState() => _AllSongsState();
}

class _AllSongsState extends ConsumerState<AllSongs> {
  bool isRefreshing = false;

  @override
  Widget build(BuildContext context) {
    final allSongsAsync = ref.watch(watchAllSongsProvider);
    final libraryService = ref.read(libraryServiceProvider);
    final musicService = ref.watch(musicServiceProvider);
    final musicNotifier = ref.read(musicServiceProvider.notifier);
    final songOperations = ref.read(songsOperationProvider);
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 750;
        final isSmall = constraints.maxWidth < 600;

        return Scaffold(
          appBar: AppBar(
            actions: [
              if (allSongsAsync.value?.isNotEmpty ?? false)
                TextButton.icon(
                  label: Text(
                    isRefreshing ? 'Refreshing' : 'Refresh',
                    style: TextStyle(fontSize: 12),
                  ),
                  onPressed: isRefreshing
                      ? null
                      : () async {
                          try {
                            setState(() => isRefreshing = true);
                            await libraryService.refreshAllSongs();
                          } catch (err) {
                            debugPrint(err.toString());
                          } finally {
                            if (mounted) {
                              setState(() => isRefreshing = false);
                            }
                          }
                        },
                  icon: isRefreshing
                      ? const CupertinoActivityIndicator()
                      : const Icon(HugeIconsStroke.refresh, size: 13),
                ),
              const SizedBox(width: 12),
            ],
            leading: IconButton(
              onPressed: () => context.back(),
              icon: const Icon(HugeIconsStroke.arrowLeft02),
            ),
            title: const Text(
              'All songs',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                Expanded(
                  child: allSongsAsync.when(
                    data: (libraryData) {
                      final songs = libraryData;
                      if (songs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: .center,
                            children: [
                              const Text("No songs found"),
                              const SizedBox(height: 20),

                              ElevatedButton(
                                onPressed: isRefreshing
                                    ? null
                                    : () async {
                                        try {
                                          setState(() => isRefreshing = true);
                                          await libraryService
                                              .refreshAllSongs();
                                        } catch (err) {
                                          debugPrint(err.toString());
                                        } finally {
                                          if (mounted) {
                                            setState(
                                              () => isRefreshing = false,
                                            );
                                          }
                                        }
                                      },
                                child: Text(
                                  isRefreshing ? "Finding Songs" : 'Find Songs',
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return !isCompact
                          ? ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 900),
                              child: GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                    ),
                                itemCount: songs.length,
                                itemBuilder: (context, index) {
                                  return SongGridItem(
                                    songOperations: songOperations,
                                    song: songs[index],
                                    musicService: musicService,
                                    musicNotifier: musicNotifier,
                                    isSmall: isSmall,
                                    isCompact: isCompact,
                                    theme: theme,
                                  );
                                },
                              ),
                            )
                          : ListView.separated(
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 2),
                              itemCount: songs.length,
                              itemBuilder: (context, index) {
                                return SongListItem(
                                  songOperations: songOperations,
                                  song: songs[index],
                                  musicService: musicService,
                                  musicNotifier: musicNotifier,
                                  isSmall: isSmall,
                                  isCompact: isCompact,
                                  theme: theme,
                                );
                              },
                            );
                    },
                    error: (err, st) => Center(
                      child: SelectableRegion(
                        selectionControls: DesktopTextSelectionControls(),
                        child: Text(st.toString()),
                      ),
                    ),
                    loading: () => const Center(
                      child: CupertinoActivityIndicator(radius: 20),
                    ),
                  ),
                ),
                const Divider(),
                const ControlsView(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SongGridItem extends StatelessWidget {
  final Song song;
  final MusicState musicService;
  final MusicService musicNotifier;
  final SongOperations songOperations;
  final bool isSmall;
  final bool isCompact;
  final ThemeData theme;

  const SongGridItem({
    super.key,
    required this.song,
    required this.musicService,
    required this.musicNotifier,
    required this.isSmall,
    required this.isCompact,
    required this.theme,
    required this.songOperations,
  });

  @override
  Widget build(BuildContext context) {
    final track = song;

    final trackFile = File(song.path);
    if (!trackFile.existsSync()) return const SizedBox.shrink();

    final currentTrack = musicService.current == null
        ? null
        : File(musicService.current!.path);
    final isCurrentPlaying =
        currentTrack != null && trackFile.path == currentTrack.path;

    return InkWell(
      borderRadius: BorderRadius.circular(2),
      onTap: () async {
        if (isCurrentPlaying) {
          context.push(const PlayerView());
          return;
        }
        await musicNotifier.playTrack(track);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          color: isCurrentPlaying
              ? theme.colorScheme.onSurface.withValues(alpha: 0.1)
              : null,
        ),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: track.artwork != null
                    ? Image.memory(
                        track.artwork!,
                        fit: BoxFit.cover,
                        cacheHeight: 100,
                        cacheWidth: 100,
                        gaplessPlayback: true,
                      )
                    : Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.1,
                          ),
                        ),
                        child: const Center(
                          child: Icon(HugeIconsStroke.musicNote03, size: 20),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              track.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: isSmall ? 12 : (isCompact ? 14 : 17)),
            ),
            Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Text(
                  formatDuration(Duration(milliseconds: track.duration)),
                  style: const TextStyle(fontSize: 10),
                ),
                IconButton(
                  onPressed: () async {
                    if (song.isFavorite == true) {
                      songOperations.removeFavorite(song.path);
                    } else {
                      songOperations.addFavorite(song.path);
                    }
                  },
                  icon: Icon(
                    song.isFavorite == true
                        ? HugeIconsSolid.favourite
                        : HugeIconsStroke.favourite,
                    size: 14,
                    color: song.isFavorite == true
                        ? theme.colorScheme.primary
                        : null,
                  ),
                ),
              ],
            ),

            if (isCurrentPlaying)
              SpectrumMountain(height: 10, player: musicNotifier.audioPlayer),
          ],
        ),
      ),
    );
  }
}

class SongListItem extends StatelessWidget {
  final Song song;
  final MusicState musicService;
  final MusicService musicNotifier;
  final SongOperations songOperations;
  final bool isSmall;
  final bool isCompact;
  final ThemeData theme;

  const SongListItem({
    super.key,
    required this.song,
    required this.musicService,
    required this.musicNotifier,
    required this.isSmall,
    required this.isCompact,
    required this.theme,
    required this.songOperations,
  });

  @override
  Widget build(BuildContext context) {
    final track = song;

    final trackFile = File(song.path);
    if (!trackFile.existsSync()) return const SizedBox.shrink();

    final currentTrack = musicService.current == null
        ? null
        : File(musicService.current!.path);
    final isCurrentPlaying =
        currentTrack != null && trackFile.path == currentTrack.path;

    final double size = isSmall ? 30 : (isCompact ? 50 : 70);

    return InkWell(
      borderRadius: BorderRadius.circular(2),
      onTap: () async {
        if (isCurrentPlaying) {
          context.push(const PlayerView());
          return;
        }
        await musicNotifier.playTrack(track);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          color: isCurrentPlaying
              ? theme.colorScheme.onSurface.withValues(alpha: 0.1)
              : null,
        ),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: size,
                  height: size,
                  child: track.artwork != null
                      ? Image.memory(
                          track.artwork!,
                          fit: BoxFit.cover,
                          cacheHeight: 100,
                          cacheWidth: 100,
                          gaplessPlayback: true,
                        )
                      : Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.1,
                            ),
                          ),
                          child: const Center(
                            child: Icon(HugeIconsStroke.musicNote03, size: 20),
                          ),
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isSmall ? 12 : (isCompact ? 14 : 17),
                        ),
                      ),
                      if (!isSmall)
                        Text(
                          track.artist ?? "Unknown",
                          style: const TextStyle(fontSize: 12),
                        ),
                      Text(
                        formatDuration(Duration(milliseconds: track.duration)),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    if (song.isFavorite == true) {
                      songOperations.removeFavorite(song.path);
                    } else {
                      songOperations.addFavorite(song.path);
                    }
                  },
                  icon: Icon(
                    song.isFavorite == true
                        ? HugeIconsSolid.favourite
                        : HugeIconsStroke.favourite,
                    size: 14,
                    color: song.isFavorite == true
                        ? theme.colorScheme.primary
                        : null,
                  ),
                ),
              ],
            ),
            if (isCurrentPlaying)
              SpectrumMountain(height: 10, player: musicNotifier.audioPlayer),
          ],
        ),
      ),
    );
  }
}
