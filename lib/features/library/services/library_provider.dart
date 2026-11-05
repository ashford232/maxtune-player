import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxtune_player/core/db/services/database_provider.dart';
import 'package:maxtune_player/features/library/services/library_service.dart';

final libraryServiceProvider = Provider((ref) => LibraryService(operations: ref.watch(songsOperationProvider)));
final allSongsProvider = FutureProvider(
  (ref) => ref.watch(libraryServiceProvider).getAllSongs(),
);
