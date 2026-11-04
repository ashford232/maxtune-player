// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxtune_player/app/services/app_providers.dart';

import 'package:maxtune_player/features/library/services/library_provider.dart';

class LibraryNotifier extends AsyncNotifier<LibraryState> {
  @override
  FutureOr<LibraryState> build() async {
    final libraryService = ref.watch(libraryServiceProvider);
    final musicNotifier = ref.watch(musicServiceProvider.notifier);
    final musicService = ref.watch(musicServiceProvider);

    final songs = await libraryService.getAllSongs();

    final existingPaths = musicService.library
        .map((song) => song.track.path)
        .toSet();

    final newSongs = songs.where(
      (song) => !existingPaths.contains(song.track.path),
    );

    musicNotifier.changeState(
      music: musicService.copyWith(
        library: [...musicService.library, ...newSongs],
      ),
    );

    return LibraryState(allSongs: songs);
  }

  Future<void> refresh() async {
    final libraryService = ref.read(libraryServiceProvider);
    final musicNotifier = ref.read(musicServiceProvider.notifier);
    final musicService = ref.read(musicServiceProvider);

    final songs = await libraryService.getAllSongs();

    final existingPaths = musicService.library
        .map((song) => song.track.path)
        .toSet();

    final newSongs = songs.where(
      (song) => !existingPaths.contains(song.track.path),
    );

    musicNotifier.changeState(
      music: musicService.copyWith(
        library: [...musicService.library, ...newSongs],
      ),
    );

    state = AsyncValue.data(LibraryState(allSongs: songs));
  }
}

class LibraryState {
  final List<SongTrack> allSongs;

  LibraryState({required this.allSongs});

  LibraryState copyWith({List<SongTrack>? allSongs}) {
    return LibraryState(allSongs: allSongs ?? this.allSongs);
  }
}

class SongTrack {
  final File track;
  final Metadata metadata;
  String get path => track.path;
  SongTrack({required this.track, required this.metadata});
}

class Metadata {
  final String? title;
  final String? artist;
  final Duration? duration;
  final String? album;
  final Uint8List? image;

  Metadata({this.title, this.artist, this.duration, this.album, this.image});

  Metadata copyWith({
    String? title,
    String? artist,
    String? album,
    Duration? duration,

    Uint8List? image,
  }) {
    return Metadata(
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      duration: duration ?? this.duration,
      image: image ?? this.image,
    );
  }
}
