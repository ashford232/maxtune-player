import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:maxtune_player/features/library/services/library_notifier.dart';

class LibraryService {
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

  Future<List<SongTrack>> getAllSongs() async {
    final home = Platform.environment['USERPROFILE'];

    if (home == null) return [];

    final folders = [
      Directory('$home\\Music'),
      Directory('$home\\Downloads'),
      Directory('$home\\Desktop'),
      Directory('$home\\OneDrive\\Music'),
      Directory('$home\\OneDrive\\Desktop'),
    ];

    final songs = <SongTrack>[];
    final visited = <String>{};

    for (final folder in folders) {
      await _scanDirectory(folder, songs, visited);
    }

    debugPrint('Total songs discovered: ${songs.length}');

    return songs;
  }

  Future<void> _scanDirectory(
    Directory directory,
    List<SongTrack> songs,
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
            final metadata = Metadata(
              title: rawMetadata.title,
              artist: rawMetadata.artist,
              album: rawMetadata.album,
              duration: rawMetadata.duration,
              image: rawMetadata.pictures.isEmpty
                  ? null
                  : rawMetadata.pictures.first.bytes,
            );
            final track = SongTrack(track: file, metadata: metadata);
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

  Future<List<SongTrack>> getSongTrack({required List<XFile> files}) async {
    try {
      List<SongTrack> songs = [];

      for (final file in files) {
        final rawMetadata = readMetadata(File(file.path), getImage: true);
        final metadata = Metadata(
          title: rawMetadata.title,
          artist: rawMetadata.artist,
          album: rawMetadata.album,
          duration: rawMetadata.duration,
          image: rawMetadata.pictures.isEmpty
              ? null
              : rawMetadata.pictures.first.bytes,
        );
        final track = SongTrack(track: File(file.path), metadata: metadata);
        songs.add(track);
      }
      return songs;
    } catch (err) {
      debugPrint(err.toString());
      return [];
    }
  }
}
