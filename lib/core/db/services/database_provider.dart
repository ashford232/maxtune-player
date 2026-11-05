import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxtune_player/core/db/app_database.dart';
import 'package:maxtune_player/core/db/operations/play_history_operations.dart';
import 'package:maxtune_player/core/db/operations/playlist_operation.dart';
import 'package:maxtune_player/core/db/operations/settings_operation.dart';
import 'package:maxtune_player/core/db/operations/song_operations.dart';

final databaseProvider = Provider((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final songsOperationProvider = Provider(
  (ref) => SongOperations(db: ref.watch(databaseProvider)),
);

final getAllSongsProvider = FutureProvider(
  (ref) => ref.watch(songsOperationProvider).getAllSongs(),
);
final watchAllSongsProvider = StreamProvider(
  (ref) => ref.watch(songsOperationProvider).watchAllSongs(),
);
final watchSongProvider = StreamProvider.family<Song?, String>(
  (ref, path) => ref.watch(songsOperationProvider).watchSongByPath(path),
);
final watchAllTodaySongProvider = StreamProvider(
  (ref) => ref.watch(songsOperationProvider).watchSongsAddedToday(),
);
final watchAllFavoriteSongsProvider = StreamProvider(
  (ref) => ref.watch(songsOperationProvider).watchFavorites(),
);

// final getAllFavoritesProvider = FutureProvider(
//   (ref) => ref.watch(favoritesOperationProvider).getFavorites(),
// );
// final watchAllFavoritesProvider = StreamProvider(
//   (ref) => ref.watch(favoritesOperationProvider).watchFavorites(),

// );

//
final playlistsOperationProvider = Provider(
  (ref) => PlaylistOperations(db: ref.watch(databaseProvider)),
);

final getAllPlaylistsProvider = FutureProvider(
  (ref) => ref.watch(playlistsOperationProvider).getAllPlaylist(),
);
final watchAllPlaylistsProvider = StreamProvider(
  (ref) => ref.watch(playlistsOperationProvider).watchAllPlaylist(),
);
//

//
final playHistoryOperationProvider = Provider(
  (ref) => PlayHistoryOperations(db: ref.watch(databaseProvider)),
);

final getAllRecentHistoryProvider = FutureProvider(
  (ref) => ref.watch(playHistoryOperationProvider).getRecentHistory(),
);
final watchAllRecentHistoryProvider = StreamProvider(
  (ref) => ref.watch(playHistoryOperationProvider).watchRecentHistory(),
);

final settingsOperationProvider = Provider(
  (ref) => SettingsOperation(db: ref.watch(databaseProvider)),
);

final themeProvider = StreamProvider(
  (ref) => ref.watch(settingsOperationProvider).watchSettings(),
);

//
