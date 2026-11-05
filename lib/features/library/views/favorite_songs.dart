import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:lite_router/lite_router.dart';
import 'package:maxtune_player/app/services/app_providers.dart';
import 'package:maxtune_player/app/views/controls.dart';
import 'package:maxtune_player/core/db/services/database_provider.dart';
import 'package:maxtune_player/features/library/views/all_songs.dart';

class FavoriteSongs extends ConsumerStatefulWidget {
  const FavoriteSongs({super.key});

  @override
  ConsumerState<FavoriteSongs> createState() => _AllSongsState();
}

class _AllSongsState extends ConsumerState<FavoriteSongs> {
  bool isRefreshing = false;

  @override
  Widget build(BuildContext context) {
    final recentSongs = ref.watch(watchAllFavoriteSongsProvider);
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
            leading: IconButton(
              onPressed: () => context.back(),
              icon: const Icon(HugeIconsStroke.arrowLeft02),
            ),
            title: const Text(
              'Favorite Songs',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                Expanded(
                  child: recentSongs.when(
                    data: (libraryData) {
                      final songs = libraryData;
                      if (songs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: .center,
                            children: [
                              const Text("No songs found"),
                              const SizedBox(height: 20),
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
                                  return ref
                                      .watch(
                                        watchSongProvider(
                                          libraryData[index].path,
                                        ),
                                      )
                                      .when(
                                        data: (song) {
                                          if (song == null) {
                                            return SizedBox.shrink();
                                          }
                                          return SongGridItem(
                                            songOperations: songOperations,
                                            song: song,
                                            musicService: musicService,
                                            musicNotifier: musicNotifier,
                                            isSmall: isSmall,
                                            isCompact: isCompact,
                                            theme: theme,
                                          );
                                        },
                                        error: (err, st) => SizedBox.shrink(),
                                        loading: () => SizedBox.shrink(),
                                      );
                                },
                              ),
                            )
                          : ListView.separated(
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 2),
                              itemCount: songs.length,
                              itemBuilder: (context, index) {
                                return ref
                                    .watch(
                                      watchSongProvider(
                                        libraryData[index].path,
                                      ),
                                    )
                                    .when(
                                      data: (song) {
                                        if (song == null) {
                                          return SizedBox.shrink();
                                        }
                                        return SongListItem(
                                          songOperations: songOperations,
                                          song: song,
                                          musicService: musicService,
                                          musicNotifier: musicNotifier,
                                          isSmall: isSmall,
                                          isCompact: isCompact,
                                          theme: theme,
                                        );
                                      },
                                      error: (err, st) => SizedBox.shrink(),
                                      loading: () => SizedBox.shrink(),
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
