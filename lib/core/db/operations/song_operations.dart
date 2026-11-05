import 'package:drift/drift.dart';
import 'package:maxtune_player/core/db/app_database.dart';

class SongOperations {
  final AppDatabase db;

  SongOperations({required this.db});

  Future<int> addSong(SongsCompanion song) {
    return db.into(db.songs).insertOnConflictUpdate(song);
  }
  Future<int>deleteSongs() {
    return db.delete(db.songs).go();
  }

  Future<List<Song>> getAllSongs() {
    return (db.select(
      db.songs,
    )..orderBy([(tbl) => OrderingTerm.asc(tbl.title)])).get();
  }

  Stream<List<Song>> watchAllSongs() {
    return (db.select(
      db.songs,
    )..orderBy([(tbl) => OrderingTerm.asc(tbl.title)])).watch();
  }


  Future<Song?> getSongByPath(String path) {
    return (db.select(
      db.songs,
    )..where((tbl) => tbl.path.equals(path))).getSingleOrNull();
  }

  Stream<Song?> watchSongByPath(String path) {
    return (db.select(
      db.songs,
    )..where((tbl) => tbl.path.equals(path))).watchSingleOrNull();
  }

  Future<bool> updateSong(Song song) {
    return db.update(db.songs).replace(song);
  }

  Future<int> deleteSong(String path) {
    return (db.delete(db.songs)..where((tbl) => tbl.path.equals(path))).go();
  }

  Future<List<Song>> getAllFavorites() {
    return (db.select(db.songs)
          ..where((tbl) => tbl.isFavorite.equals(true))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.title)]))
        .get();
  }

  Stream<List<Song>> watchFavorites() {
    return (db.select(db.songs)
          ..where((tbl) => tbl.isFavorite.equals(true))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.title)]))
        .watch();
  }

  Future<int> addFavorite(String path) {
    return (db.update(db.songs)..where((tbl) => tbl.path.equals(path))).write(
      const SongsCompanion(isFavorite: Value(true)),
    );
  }

  Future<int> removeFavorite(String id) {
    return (db.update(db.songs)..where((tbl) => tbl.path.equals(id))).write(
      const SongsCompanion(isFavorite: Value(false)),
    );
  }

  Future<int> clearFavorites() {
    return (db.update(db.songs)..where((tbl) => tbl.isFavorite.equals(true)))
        .write(const SongsCompanion(isFavorite: Value(false)));
  }

  Future<List<Song>> getSongsAddedToday() {
  final now = DateTime.now();

  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));

  return (db.select(db.songs)
        ..where(
          (tbl) =>
              tbl.addedAt.isBiggerOrEqualValue(startOfDay) &
              tbl.addedAt.isSmallerThanValue(endOfDay),
        )
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.addedAt)]))
      .get();
}
  Stream<List<Song>> watchSongsAddedToday() {
  final now = DateTime.now();

  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));

  return (db.select(db.songs)
        ..where(
          (tbl) =>
              tbl.addedAt.isBiggerOrEqualValue(startOfDay) &
              tbl.addedAt.isSmallerThanValue(endOfDay),
        )
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.addedAt)]))
      .watch();
}
}
