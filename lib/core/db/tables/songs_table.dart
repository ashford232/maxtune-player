import 'package:drift/drift.dart';

class Songs extends Table {
  TextColumn get artist => text().nullable()();
  TextColumn get album => text().nullable()();
  TextColumn get title => text()();
  BlobColumn get artwork => blob().nullable()();
  TextColumn get path => text()();

  BoolColumn get isFavorite => boolean().nullable()();
  IntColumn get duration => integer()();
  DateTimeColumn get addedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {path};
}
