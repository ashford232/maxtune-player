import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxtune_player/features/library/services/library_notifier.dart';
import 'package:maxtune_player/features/library/services/library_service.dart';

final libraryServiceProvider = Provider((ref) => LibraryService());
final libraryProvider = AsyncNotifierProvider(() => LibraryNotifier());
