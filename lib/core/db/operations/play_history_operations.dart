import 'package:drift/drift.dart';
import 'package:maxtune_player/core/db/app_database.dart';

class PlayHistoryOperations {
  final AppDatabase db;

  PlayHistoryOperations({required this.db});

  Future<int> addToHistory(String path) {
    return db
        .into(db.playHistory)
        .insert(
          PlayHistoryCompanion.insert(songId: path, addedAt: DateTime.now()),
        );
  }

  Future<List<PlayHistoryData>> getRecentHistory({int limit = 100}) {
    return (db.select(db.playHistory)
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.addedAt)])
          ..limit(limit))
        .get();
  }

  Stream<List<PlayHistoryData>> watchRecentHistory({int limit = 100}) {
    return (db.select(db.playHistory)
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.addedAt)])
          ..limit(limit))
        .watch();
  }

  Future<int> clearHistory() {
    return db.delete(db.playHistory).go();
  }
}
