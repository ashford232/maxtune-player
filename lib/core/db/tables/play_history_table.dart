import 'package:drift/drift.dart';

class PlayHistory extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get path => text()();
  DateTimeColumn get addedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
