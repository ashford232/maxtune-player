import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxtune_player/features/library/services/library_notifier.dart';
import 'package:mpv_audio_kit/mpv_audio_kit.dart';
import 'package:path/path.dart' as p;

class MusicService extends Notifier<MusicState> {
  late final Player audioPlayer;
  final List<StreamSubscription> _subscriptions = [];

  @override
  MusicState build() {
    audioPlayer = Player();

    audioPlayer.setSpectrum(
      const SpectrumSettings(
        fftSize: 2048,
        bandCount: 48,
        bandLowHz: 20.0,
        bandHighHz: 20000.0,
        window: WindowFunction.hann,
        emitInterval: Duration(milliseconds: 33),
        attackSmoothing: 0.5,
        releaseSmoothing: 0.1,
        minDb: -100.0,
        maxDb: -30.0,
        overlapFactor: 4,
      ),
    );

    audioPlayer.setMediaSession(const MediaSession());

    _subscriptions.add(
      audioPlayer.stream.mediaSessionCommands.listen((command) {
        if (command is MediaSessionCommandNext) {
          playNext();
        } else if (command is MediaSessionCommandPrevious) {
          playPrevious();
        } else if (command is MediaSessionCommandPlay) {
          audioPlayer.play();
        } else if (command is MediaSessionCommandPause) {
          audioPlayer.pause();
        } else if (command is MediaSessionCommandPlayPause) {
          togglePlayPause();
        }
      }),
    );

    _subscriptions.add(
      audioPlayer.stream.playlist.listen((playlist) {
        if (playlist.index >= 0 && playlist.index < state.library.length) {
          final activeFile = state.library[playlist.index];
          if (state.current?.track.path != activeFile.track.path) {
            state = state.copyWith(current: activeFile);

            // Update OS lock-screen metadata for the new track
            final fileName = p.basename(activeFile.track.path);
            audioPlayer.setMediaSession(
              MediaSession(title: fileName, artist: 'Maxtune Player'),
            );
          }
        }
      }),
    );

    _subscriptions.add(
      audioPlayer.stream.playing.listen((isPlaying) {
        state = state.copyWith(isPlaying: isPlaying);
      }),
    );

    ref.onDispose(() {
      for (final sub in _subscriptions) {
        sub.cancel();
      }
      audioPlayer.dispose();
    });

    return MusicState();
  }

  @override
  bool updateShouldNotify(MusicState previous, MusicState next) {
    return previous.isPlaying != next.isPlaying ||
        previous.volume != next.volume ||
        previous.current?.track.path != next.current?.track.path ||
        previous.library.length != next.library.length;
  }

  void addToLibrary(SongTrack file) {
    state = state.copyWith(library: [...state.library, file]);
  }

  Future<void> playFromLibrary(
    List<SongTrack> library,
    SongTrack targetFile,
  ) async {
    final targetIndex = library.indexWhere(
      (track) => track.track.path == targetFile.track.path,
    );

    if (targetIndex == -1) {
      debugPrint('Selected song not found in library.');
      return;
    }

    try {
      final mediaList = library.map((file) => Media(file.track.path)).toList();

      await audioPlayer.openAll(mediaList, index: targetIndex);
      await audioPlayer.play();

      state = state.copyWith(current: targetFile, isPlaying: true);

      final fileName = p.basename(targetFile.track.path);
      await audioPlayer.setMediaSession(
        MediaSession(title: fileName, artist: 'Maxtune Player'),
      );
    } catch (e, st) {
      debugPrint('Error playing from library: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  Future<void> playTrack(SongTrack file) async {
    try {
      if (!await File(file.track.path).exists()) {
        debugPrint('File does not exist: ${file.track.path}');
        return;
      }

      final exists = state.library.any(
        (song) => song.track.path == file.track.path,
      );

      final updatedLibrary = exists ? state.library : [...state.library, file];

      if (!exists) {
        state = state.copyWith(library: updatedLibrary);
      }

      await playFromLibrary(updatedLibrary, file);
    } catch (e, st) {
      debugPrint('Playback error: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  Future<void> togglePlayPause() async {
    if (audioPlayer.state.playing) {
      await audioPlayer.pause();
    } else {
      await audioPlayer.play();
    }
  }

  Future<void> seek(Duration position) async {
    await audioPlayer.seek(position);
  }

  Future<void> setVolume(double volume) async {
    await audioPlayer.setVolume(volume * 100.0);
    state = state.copyWith(volume: volume);
  }

  Future<void> playNext() async {
    await audioPlayer.nextPlaylist();
  }

  Future<void> playPrevious() async {
    await audioPlayer.previousPlaylist();
  }

  Future<void> removeMissingFiles() async {
    final validFiles = <SongTrack>[];
    SongTrack? activeTrack = state.current;

    for (final file in state.library) {
      if (await File(file.track.path).exists()) {
        validFiles.add(file);
      } else if (state.current?.track.path == file.track.path) {
        activeTrack = null;
      }
    }

    if (validFiles.length != state.library.length) {
      state = state.copyWith(library: validFiles, current: activeTrack);

      if (validFiles.isNotEmpty) {
        final mediaList = validFiles.map((f) => Media(f.track.path)).toList();
        int targetIndex = 0;

        if (activeTrack != null) {
          targetIndex = validFiles.indexWhere(
            (f) => f.track.path == activeTrack!.track.path,
          );
          if (targetIndex == -1) targetIndex = 0;
        }

        await audioPlayer.openAll(mediaList, index: targetIndex);
      } else {
        await audioPlayer.stop();
        state = state.copyWith(current: null, isPlaying: false);
      }
    }
  }

  void changeState({required MusicState music}) {
    state = music;
  }
}

class MusicState {
  final bool isPlaying;
  final double volume;
  final List<SongTrack> library;
  final SongTrack? current;

  const MusicState({
    this.isPlaying = false,
    this.volume = 0.8,
    this.library = const [],
    this.current,
  });

  MusicState copyWith({
    bool? isPlaying,
    double? volume,
    List<SongTrack>? library,
    SongTrack? current,
  }) {
    return MusicState(
      isPlaying: isPlaying ?? this.isPlaying,
      volume: volume ?? this.volume,
      library: library ?? this.library,
      current: current ?? this.current,
    );
  }
}
