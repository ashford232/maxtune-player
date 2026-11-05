import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxtune_player/core/db/app_database.dart';
import 'package:maxtune_player/core/db/services/database_provider.dart';
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
      audioPlayer.stream.playlist.listen((playlist) async {
        if (playlist.index >= 0 && playlist.index < playlist.items.length) {
          final activeMedia = playlist.items[playlist.index];
          final path = activeMedia.uri;

          final songOperations = ref.read(songsOperationProvider);
          final activeSong = await songOperations.getSongByPath(path);

          if (activeSong != null && state.current?.path != activeSong.path) {
            state = state.copyWith(current: activeSong);

            final fileName = p.basename(activeSong.path);
            audioPlayer.setMediaSession(
              MediaSession(
                title: fileName,
                artist: activeSong.artist ?? 'Maxtune Player',
              ),
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

    // Initialize and listen to database settings
    _initSettings();

    ref.onDispose(() {
      for (final sub in _subscriptions) {
        sub.cancel();
      }
      audioPlayer.dispose();
    });

    return const MusicState();
  }

  Future<void> _initSettings() async {
    try {
      final settingsOps = ref.read(settingsOperationProvider);

      // Fetch initial settings and apply them to the player
      final initialSettings = await settingsOps.getSettings();
      _applySettings(initialSettings);

      // Watch for live settings updates from the database
      _subscriptions.add(
        settingsOps.watchSettings().listen((settings) {
          _applySettings(settings);
        }),
      );
    } catch (e, st) {
      debugPrint('Error initializing settings in MusicService: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  void _applySettings(AppSetting settings) {
    // Apply speed and pitch directly to mpv audio player
    audioPlayer.setRate(settings.playbackSpeed);
    audioPlayer.setPitch(settings.pitch);

    // Keep state updated with current settings
    state = state.copyWith(
      playbackSpeed: settings.playbackSpeed,
      pitch: settings.pitch,
    );
  }

  @override
  bool updateShouldNotify(MusicState previous, MusicState next) {
    return previous.isPlaying != next.isPlaying ||
        previous.volume != next.volume ||
        previous.playbackSpeed != next.playbackSpeed ||
        previous.pitch != next.pitch ||
        previous.current?.path != next.current?.path;
  }

  Future<void> playSongs(List<Song> songs, Song targetSong) async {
    final targetIndex = songs.indexWhere(
      (track) => track.path == targetSong.path,
    );

    if (targetIndex == -1) {
      debugPrint('Selected song not found in song list.');
      return;
    }

    try {
      final mediaList = songs.map((file) => Media(file.path)).toList();

      await audioPlayer.openAll(mediaList, index: targetIndex);
      await audioPlayer.play();

      state = state.copyWith(current: targetSong, isPlaying: true);

      final fileName = p.basename(targetSong.path);
      await audioPlayer.setMediaSession(
        MediaSession(
          title: fileName,
          artist: targetSong.artist ?? 'Maxtune Player',
        ),
      );
    } catch (e, st) {
      debugPrint('Error playing songs: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  Future<void> playTrack(Song file) async {
    try {
      if (!await File(file.path).exists()) {
        debugPrint('File does not exist: ${file.path}');
        return;
      }

      final songOperations = ref.read(songsOperationProvider);
      final historyOperations = ref.read(playHistoryOperationProvider);

      final allSongs = await songOperations.getAllSongs();
      final exists = allSongs.any((song) => song.path == file.path);

      if (!exists) {
        await songOperations.addSong(
          SongsCompanion.insert(
            title: file.title,
            path: file.path,
            duration: file.duration,
            addedAt: DateTime.now(),
          ),
        );
      }
      await historyOperations.addToHistory(file.path);

      final updatedQueue = await songOperations.getAllSongs();
      await playSongs(updatedQueue.isEmpty ? [file] : updatedQueue, file);
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
    final songOperations = ref.read(songsOperationProvider);
    final allSongs = await songOperations.getAllSongs();
    Song? activeTrack = state.current;

    for (final song in allSongs) {
      if (!await File(song.path).exists()) {
        await songOperations.deleteSong(song.path);
        if (state.current?.path == song.path) {
          activeTrack = null;
        }
      }
    }

    final validSongs = await songOperations.getAllSongs();
    if (validSongs.isNotEmpty) {
      final mediaList = validSongs.map((f) => Media(f.path)).toList();
      int targetIndex = 0;

      if (activeTrack != null) {
        targetIndex = validSongs.indexWhere((f) => f.path == activeTrack!.path);
        if (targetIndex == -1) targetIndex = 0;
      }

      await audioPlayer.openAll(mediaList, index: targetIndex);
    } else {
      await audioPlayer.stop();
      state = state.copyWith(current: null, isPlaying: false);
    }
  }

  void changeState({required MusicState music}) {
    state = music;
  }
}

class MusicState {
  final bool isPlaying;
  final double volume;
  final double playbackSpeed;
  final double pitch;
  final Song? current;

  const MusicState({
    this.isPlaying = false,
    this.volume = 0.8,
    this.playbackSpeed = 1.0,
    this.pitch = 1.0,
    this.current,
  });

  MusicState copyWith({
    bool? isPlaying,
    double? volume,
    double? playbackSpeed,
    double? pitch,
    Song? current,
  }) {
    return MusicState(
      isPlaying: isPlaying ?? this.isPlaying,
      volume: volume ?? this.volume,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      pitch: pitch ?? this.pitch,
      current: current ?? this.current,
    );
  }
}