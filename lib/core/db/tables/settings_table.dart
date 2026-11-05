import 'package:drift/drift.dart';

@DataClassName('AppSetting')
class SettingsTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Appearance
  TextColumn get theme => text().withDefault(const Constant('system'))();

  // Playback
  RealColumn get playbackSpeed => real().withDefault(const Constant(1.0))();

  RealColumn get pitch => real().withDefault(const Constant(1.0))();
}
