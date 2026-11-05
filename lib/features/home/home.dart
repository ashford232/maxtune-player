import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:maxtune_player/app/services/app_providers.dart';
import 'package:maxtune_player/app/services/music_service.dart';
import 'package:maxtune_player/core/db/services/database_provider.dart';
import 'package:maxtune_player/features/library/views/all_songs.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  MusicState get musicService => ref.watch(musicServiceProvider);
  MusicService get musicNotifier => ref.watch(musicServiceProvider.notifier);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final musicService = ref.watch(musicServiceProvider);
    final musicNotifier = ref.watch(musicServiceProvider.notifier);
    final musicsAsync = ref.watch(watchAllTodaySongProvider);
    final songOperations = ref.read(songsOperationProvider);
    return Scaffold(
      body: musicsAsync.when(
        data: (library) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 750;
              final isSmall = constraints.maxWidth < 600;

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 24,
                ),
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: library.isEmpty && musicService.current == null
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
                                constraints: const BoxConstraints(
                                  maxWidth: 350,
                                ),
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
                                        // final res = await openFiles();
                                        // final songs = await ref
                                        //     .watch(libraryServiceProvider)
                                        //     .getSongTrack(files: res);
                                        // musicNotifier.changeState(
                                        //   music: musicService.copyWith(
                                        //     library: songs,
                                        //     current: songs.isNotEmpty
                                        //         ? songs.first
                                        //         : null,
                                        //   ),
                                        // );

                                        // if (res.isNotEmpty) {
                                        //   musicNotifier.playTrack(songs.first);
                                        //  }
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
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                ),
                            itemCount: library.length,
                            itemBuilder: (context, index) {
                            
                              final track = library[index];
                              final trackFile = File(library[index].path);
                            
                              if (!trackFile.existsSync()) {
                                return SizedBox.shrink();
                              }
                              return SongGridItem(
                                song: track,
                                musicService: musicService,
                                musicNotifier: musicNotifier,
                                isSmall: isSmall,
                                isCompact: isCompact,
                                theme: theme,
                                songOperations: songOperations,
                              );
                            },
                          ),
                        )
                      : ListView.separated(
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 2),
                          itemCount: library.length,
                          itemBuilder: (context, index) {
                            final track = library[index];
                            final trackFile = File(library[index].path);
                            if (!trackFile.existsSync()) {
                              return SizedBox.shrink();
                            }

                            return SongListItem(
                              song: track,
                              musicService: musicService,
                              musicNotifier: musicNotifier,
                              isSmall: isSmall,
                              isCompact: isCompact,
                              theme: theme,
                              songOperations: songOperations,
                            );
                          },
                        ),
                ),
              );
            },
          );
        },
        error: (err, st) => Center(child: Text(err.toString())),
        loading: () => SizedBox(),
      ),
    );
  }
}
