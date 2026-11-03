import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxtune_player/app/services/music_service.dart';
import 'package:maxtune_player/app/services/nav_service.dart';

final navProvider = NotifierProvider(() => NavigationService());
final musicServiceProvider = NotifierProvider(() => MusicService());
