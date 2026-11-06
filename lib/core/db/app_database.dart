import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:maxtune_player/core/db/tables/play_history_table.dart';
import 'package:maxtune_player/core/db/tables/playlists_table.dart';
import 'package:maxtune_player/core/db/tables/settings_table.dart';
import 'package:maxtune_player/core/db/tables/songs_table.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Songs, Playlists,  PlayHistory, SettingsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationSupportDirectory();
    final file = File(p.join(directory.path, "maxtune_player.sqlite"));
    return NativeDatabase(file);
  });
}
