import 'package:maxtune_player/core/db/app_database.dart';

class PlaylistOperations {
  final AppDatabase db;

  PlaylistOperations({required this.db});

  Future<int> createPlaylist(PlaylistsCompanion playlist) {
    return db.into(db.playlists).insert(playlist);
  }

  Future<List<Playlist>> getAllPlaylist() {
    return db.select(db.playlists).get();
  }

  Stream<List<Playlist>> watchAllPlaylist() {
    return db.select(db.playlists).watch();
  }

  Future<Playlist?> getPlaylistById(String id) {
    return (db.select(
      db.playlists,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<bool> updatePlaylist(Playlist playlist) {
    return db.update(db.playlists).replace(playlist);
  }

  Future<int> deletePlaylist(String id) {
    return (db.delete(db.playlists)..where((tbl) => tbl.id.equals(id))).go();
  }
}
