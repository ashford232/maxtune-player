import 'package:drift/drift.dart';
import 'package:maxtune_player/core/db/app_database.dart';

class SettingsOperation {
  final AppDatabase db;

  SettingsOperation({required this.db});

  // Get settings or create default settings.
  Future<AppSetting> getSettings() async {
    final existing = await (db.select(
      db.settingsTable,
    )..where((t) => t.id.equals(1))).getSingleOrNull();

    if (existing != null) return existing;

    await db
        .into(db.settingsTable)
        .insert(const SettingsTableCompanion(id: Value(1)));

    return (db.select(
      db.settingsTable,
    )..where((t) => t.id.equals(1))).getSingle();
  }

  Stream<AppSetting> watchSettings() {
    return (db.select(
      db.settingsTable,
    )..where((t) => t.id.equals(1))).watchSingle();
  }

  Future<bool> updateSettings(AppSetting setting) {
    return db.update(db.settingsTable).replace(setting);
  }

  Future<int> updateSettingsPartial(SettingsTableCompanion companion) {
    return (db.update(
      db.settingsTable,
    )..where((t) => t.id.equals(1))).write(companion);
  }

  // Update theme.
  Future<int> updateTheme(String theme) {
    return updateSettingsPartial(SettingsTableCompanion(theme: Value(theme)));
  }

  // Update playback speed.
  Future<int> updatePlaybackSpeed(double speed) {
    return updateSettingsPartial(
      SettingsTableCompanion(playbackSpeed: Value(speed)),
    );
  }

  // Update pitch.
  Future<int> updatePitch(double pitch) {
    return updateSettingsPartial(SettingsTableCompanion(pitch: Value(pitch)));
  }

  // Reset all settings to defaults.
  Future<int> resetSettings() {
    return updateSettingsPartial(
      const SettingsTableCompanion(
        theme: Value('darkPale'),


        playbackSpeed: Value(1),
        pitch: Value(1),
      ),
    );
  }
}
