import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:drift/drift.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:maxtune_player/core/db/app_database.dart';
import 'package:maxtune_player/core/db/operations/song_operations.dart';
import 'package:path/path.dart' as p;

class LibraryService {
  final SongOperations operations;
  static const _extensions = {
    '.mp3',
    '.wav',
    '.flac',
    '.aac',
    '.m4a',
    '.ogg',
    '.opus',
    '.wma',
    '.aiff',
    '.ape',
  };

  LibraryService({required this.operations});

  Future<List<Song>> getAllSongs() async {
    final home = Platform.environment['USERPROFILE'];

    if (home == null) return [];

    final folders = [
      Directory('$home\\Music'),
      Directory('$home\\Downloads'),
      Directory('$home\\Desktop'),
      Directory('$home\\OneDrive\\Music'),
      Directory('$home\\OneDrive\\Desktop'),
    ];

    final songs = <Song>[];
    final visited = <String>{};

    for (final folder in folders) {
      await _scanDirectory(folder, songs, visited);
    }

    debugPrint('Total songs discovered: ${songs.length}');

    return songs;
  }

  Future<void> _scanDirectory(
    Directory directory,
    List<Song> songs,
    Set<String> visited,
  ) async {
    try {
      if (!await directory.exists()) return;

      final path = directory.absolute.path.toLowerCase();

      if (!visited.add(path)) return;

      await for (final entity in directory.list(
        recursive: false,
        followLinks: false,
      )) {
        if (entity is File) {
          final filePath = entity.path.toLowerCase();

          if (_extensions.any(filePath.endsWith)) {
            final file = entity;
            final rawMetadata = readMetadata(file, getImage: true);

            final track = Song(
              path: file.path,
              addedAt: DateTime.now(),
              duration: rawMetadata.duration?.inMilliseconds ?? 0,
              title: rawMetadata.title ?? p.basename(file.path),
              album: rawMetadata.album,
              artist: rawMetadata.artist,
              artwork: rawMetadata.pictures.isEmpty
                  ? null
                  : rawMetadata.pictures.first.bytes,
            );
            songs.add(track);
          }
        } else if (entity is Directory) {
          await _scanDirectory(entity, songs, visited);
        }
      }
    } on FileSystemException catch (e) {
      debugPrint('Cannot access ${directory.path}: ${e.message}');
    }
  }

  Future<List<Song>> getSongFromFile(List<XFile> files) async {
    final List<Song> songs = [];
    for (final entity in files) {
      final filePath = entity.path.toLowerCase();

      if (_extensions.any(filePath.endsWith)) {
        final file = entity;
        final rawMetadata = readMetadata(File(entity.path), getImage: true);

        final track = Song(
          path: file.path,
          addedAt: DateTime.now(),
          duration: rawMetadata.duration?.inMilliseconds ?? 0,
          title: rawMetadata.title ?? p.basename(file.path),
          album: rawMetadata.album,
          artist: rawMetadata.artist,
          artwork: rawMetadata.pictures.isEmpty
              ? null
              : rawMetadata.pictures.first.bytes,
        );
        songs.add(track);
        final song = SongsCompanion(
          duration: Value(track.duration),
          path: Value(track.path),
          title: Value(track.title),
          album: Value(track.album),
          artist: Value(track.artist),
          addedAt: Value(DateTime.now()),
          artwork: Value(track.artwork),
        );
        await operations.addSong(song);
      }
    }
    return songs;
  }

  Future<void> refreshAllSongs() async {
    final songs = await getAllSongs();
    for (final s in songs) {
      final song = SongsCompanion(
        duration: Value(s.duration),
        path: Value(s.path),
        title: Value(s.title),
        album: Value(s.album),
        artist: Value(s.artist),
        addedAt: Value(DateTime.now()),
        artwork: Value(s.artwork),
      );
      await operations.addSong(song);
    }
  }
}
