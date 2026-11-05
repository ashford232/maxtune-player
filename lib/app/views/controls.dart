import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:lite_router/lite_router.dart';
import 'package:maxtune_player/app/services/app_providers.dart';
import 'package:maxtune_player/app/services/music_service.dart';
import 'package:maxtune_player/app/views/player_view.dart';
import 'package:maxtune_player/core/db/services/database_provider.dart';
import 'package:path/path.dart' as p;

class ControlsView extends ConsumerStatefulWidget {
  final bool? isPlayer;
  const ControlsView({super.key, this.isPlayer});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ControlsViewState();
}

class _ControlsViewState extends ConsumerState<ControlsView> {
  double get _volumeValue => musicService.volume;
  bool get _isMuted => musicService.volume == 0;

  MusicState get musicService => ref.watch(musicServiceProvider);
  MusicService get musicNotifier => ref.watch(musicServiceProvider.notifier);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final current = musicService.current;
    final fileName = current?.path == null ? "" : p.basename(current!.path);
    File? track = current?.path == null ? null : File(current!.path);
    if (track != null && !track.existsSync()) {
      track = null;
    }
    final library = ref.watch(watchAllSongsProvider).value;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 600;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12),
          child: isSmall
              ? _buildCompactPlayer(
                  theme,
                  fileName,
                  current != null,
                  library != null && library.isNotEmpty,
                )
              : _buildExpandedPlayer(
                  theme,
                  fileName,
                  current != null,
                  isSmall,
                  library != null && library.isNotEmpty,
                ),
        );
      },
    );
  }

  Widget _buildAlbumArtButton({bool isCompact = false}) {
    return Builder(
      builder: (context) {
        final double size = isCompact ? 50 : 70;
        final theme = Theme.of(context);
        return ClipRRect(
          borderRadius: .circular(2),

          child: Container(
            decoration: BoxDecoration(
              borderRadius: .circular(2),
              color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            ),
            width: size,
            height: size,
            child: musicService.current?.artwork != null
                ? Image.memory(
                    musicService.current!.artwork!,
                    fit: .cover,
                    cacheHeight: 100,
                    cacheWidth: 100,
                    width: size,
                    height: size,
                    gaplessPlayback: true,
                  )
                : Center(child: Icon(HugeIconsStroke.musicNote03, size: 20)),
          ),
        );
      },
    );
  }

  Widget _buildTrackInfo({
    required String fileName,
    required bool hasCurrent,
    bool isCompact = false,
  }) {
    final title = hasCurrent
        ? musicService.current?.title ??
              (fileName.isNotEmpty ? fileName : "Unknown")
        : 'Playing something';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: isCompact ? FontWeight.w600 : FontWeight.w500,
            fontSize: isCompact ? 13 : 16,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaybackControls({required bool hasLibrary}) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Previous Button
        IconButton(
          onPressed: hasLibrary ? () => musicNotifier.playPrevious() : null,
          icon: const Icon(HugeIconsSolid.previous, size: 20),
          tooltip: 'Previous',
        ),
        const SizedBox(width: 4),

        // Play / Pause Button
        IconButton(
          style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: const EdgeInsets.all(10),
            shape: const CircleBorder(),
          ),
          onPressed: musicService.current != null
              ? () => musicNotifier.togglePlayPause()
              : null,
          icon: Icon(
            musicService.isPlaying ? HugeIconsSolid.pause : HugeIconsSolid.play,
            size: 24,
          ),
          tooltip: 'Play/Pause',
        ),
        const SizedBox(width: 4),

        // Next Button
        IconButton(
          onPressed: hasLibrary ? () => musicNotifier.playNext() : null,
          icon: const Icon(HugeIconsSolid.next, size: 20),
          tooltip: 'Next',
        ),
      ],
    );
  }

  Widget _buildVolumeControl() {
    return SizedBox(
      width: 150,
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (_isMuted) {
                musicNotifier.setVolume(0.8);
              } else {
                musicNotifier.setVolume(0.0);
              }
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
              child: SliderTheme(
                data: SliderThemeData(
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 5,
                    disabledThumbRadius: 5,
                  ),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 1),
                ),
                child: Slider(
                  min: 0.0,
                  max: 1.0,
                  value: _isMuted ? 0.0 : _volumeValue.clamp(0.0, 1.0),
                  onChanged: (value) {
                    musicNotifier.setVolume(value);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactPlayer(
    ThemeData theme,
    String fileName,
    bool hasCurrent,
    bool hasLibrary,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: widget.isPlayer == true
              ? null
              : () {
                  context.push(PlayerView());
                },
          child: Row(
            children: [
              _buildAlbumArtButton(isCompact: true),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTrackInfo(
                  fileName: fileName,
                  hasCurrent: hasCurrent,
                  isCompact: true,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _buildPlaybackControls(hasLibrary: hasLibrary),
      ],
    );
  }

  Widget _buildExpandedPlayer(
    ThemeData theme,
    String fileName,
    bool hasCurrent,
    bool hasLibrary,
    bool isSmall,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkWell(
          onTap: widget.isPlayer == true
              ? null
              : () {
                  context.push(PlayerView());
                },
          child: _buildAlbumArtButton(),
        ),
        const SizedBox(width: 16),

        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTrackInfo(fileName: fileName, hasCurrent: hasCurrent),
              const SizedBox(height: 4),

              StreamBuilder<Duration>(
                stream: musicNotifier.audioPlayer.stream.position,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final player = musicNotifier.audioPlayer;

                  return StreamBuilder<Duration>(
                    stream: player.stream.duration,
                    builder: (context, durationSnapshot) {
                      final duration = durationSnapshot.data ?? Duration.zero;

                      final maxSeconds = duration.inSeconds.toDouble();
                      final currentSeconds = position.inSeconds
                          .toDouble()
                          .clamp(0.0, maxSeconds > 0 ? maxSeconds : 1.0);

                      return Row(
                        children: [
                          Text(
                            formatDuration(position),
                            style: const TextStyle(fontSize: 10),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: widget.isPlayer == true && !isSmall
                                ? SizedBox()
                                : SizedBox(
                                    height: 20,
                                    child: SliderTheme(
                                      data: SliderThemeData(
                                        thumbShape: const RoundSliderThumbShape(
                                          enabledThumbRadius: 5,
                                          disabledThumbRadius: 5,
                                        ),
                                        overlayShape:
                                            const RoundSliderOverlayShape(
                                              overlayRadius: 1,
                                            ),
                                      ),
                                      child: Slider(
                                        min: 0.0,
                                        max: maxSeconds > 0 ? maxSeconds : 1.0,
                                        value: currentSeconds,
                                        onChanged: (value) {
                                          player.seek(
                                            Duration(seconds: value.toInt()),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              formatDuration(duration),
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(width: 20),
        _buildPlaybackControls(hasLibrary: hasLibrary),
        const SizedBox(width: 20),
        _buildVolumeControl(),
      ],
    );
  }
}

String formatDuration(Duration d) {
  final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '${d.inHours > 0 ? '${d.inHours}:' : ''}$minutes:$seconds';
}
