import 'dart:async';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mpv_audio_kit/mpv_audio_kit.dart';
import 'package:path/path.dart' as p;

class MusicService extends Notifier<MusicState> {
  late final Player audioPlayer;

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
    });

    audioPlayer.stream.playlist.listen((playlist) {
      if (playlist.index >= 0 && playlist.index < state.library.length) {
        final activeFile = state.library[playlist.index];
        if (state.current?.path != activeFile.path) {
          state = state.copyWith(current: activeFile);

          // Update OS lock-screen metadata for the new track
          final fileName = p.basename(activeFile.path);
          audioPlayer.setMediaSession(
            MediaSession(title: fileName, artist: 'Maxtune Player'),
          );
        }
      }
    });

    // 4. Track playback state changes
    audioPlayer.stream.playing.listen((isPlaying) {
      state = state.copyWith(isPlaying: isPlaying);
    });

    ref.onDispose(() {
      audioPlayer.dispose();
    });

    return MusicState();
  }

  Future<void> disposePlayer() async {
    await audioPlayer.dispose();
  }

  Future<void> playFromLibrary(List<XFile> library, XFile targetFile) async {
    try {
      state = state.copyWith(library: library);

      final mediaList = library.map((file) => Media(file.path)).toList();
      final targetIndex = library.indexWhere(
        (file) => file.path == targetFile.path,
      );

      if (targetIndex != -1) {
        await audioPlayer.openAll(mediaList, index: targetIndex);
        await audioPlayer.play();

        state = state.copyWith(current: targetFile, isPlaying: true);

        final fileName = p.basename(targetFile.path);
        await audioPlayer.setMediaSession(
          MediaSession(title: fileName, artist: 'Maxtune Player'),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> playTrack(XFile file) async {
    if (state.library.isNotEmpty) {
      await playFromLibrary(state.library, file);
    } else {
      try {
        await audioPlayer.open(Media(file.path));
        await audioPlayer.play();
        state = state.copyWith(current: file, isPlaying: true);
      } catch (e) {
        debugPrint(e.toString());
      }
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

  // Simplified native playlist triggers
  Future<void> playNext() async {
    await audioPlayer.nextPlaylist();
  }

  Future<void> playPrevious() async {
    await audioPlayer.previousPlaylist();
  }

  void changeState({required MusicState music}) {
    state = music;
  }
}

class MusicState {
  final bool isPlaying;
  final double volume;
  final List<XFile> library;
  final XFile? current;

  MusicState({
    this.isPlaying = false,
    this.volume = 0.8,
    this.library = const [],
    this.current,
  });

  MusicState copyWith({
    bool? isPlaying,
    double? volume,
    List<XFile>? library,
    XFile? current,
  }) {
    return MusicState(
      isPlaying: isPlaying ?? this.isPlaying,
      volume: volume ?? this.volume,
      library: library ?? this.library,
      current: current ?? this.current,
    );
  }
}
