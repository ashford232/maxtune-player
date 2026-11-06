import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_router/lite_router.dart';
import 'package:maxtune_player/app/services/app_providers.dart';
import 'package:maxtune_player/app/views/view.dart';
import 'package:maxtune_player/core/db/services/database_provider.dart';
import 'package:maxtune_player/features/library/services/library_provider.dart';
import 'package:maxtune_player/shared/themes/app_themes.dart';
import 'package:mpv_audio_kit/mpv_audio_kit.dart';
import 'package:window_manager/window_manager.dart';
import 'package:windows_single_instance/windows_single_instance.dart';

// Global callback to bridge the static single-instance listener with widget state
typedef SecondInstanceCallback = void Function(List<String> args);
SecondInstanceCallback? onSecondInstanceReceived;

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  MpvAudioKit.ensureInitialized();

  await WindowsSingleInstance.ensureSingleInstance(
    args,
    'maxtune_player',
    onSecondWindow: (newArgs) {
      // Triggered when a second instance opens with file arguments
      onSecondInstanceReceived?.call(newArgs);
    },
  );

  runApp(
    ProviderScope(child: MaxTunePlayer(initials: args.isNotEmpty ? args : [])),
  );

  await windowManager.ensureInitialized();
  await windowManager.waitUntilReadyToShow(
    const WindowOptions(minimumSize: Size(460, 380), title: 'MaxTune Player'),
    () async {
      await windowManager.show();
      await windowManager.focus();
    },
  );
}

final router = LiteRouter();

class MaxTunePlayer extends ConsumerStatefulWidget {
  final List<String> initials;
  const MaxTunePlayer({super.key, this.initials = const []});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MaxTunePlayerState();
}

class _MaxTunePlayerState extends ConsumerState<MaxTunePlayer> {
  @override
  void initState() {
    super.initState();
    addInitial();

    // Listen for arguments passed if another instance is opened later
    onSecondInstanceReceived = (args) {
      openAudioFiles(args);
    };
  }

  @override
  void dispose() {
    if (onSecondInstanceReceived != null) {
      onSecondInstanceReceived = null;
    }
    super.dispose();
  }

  Future<void> openAudioFiles(List<String> paths) async {
    final files = paths.where(isAudioFile).map((path) => XFile(path)).toList();

    if (files.isEmpty) return;

    final songs = await ref.read(libraryServiceProvider).getSongFromFile(files);

    if (songs.isEmpty) return;

    await ref.read(musicServiceProvider.notifier).playTrack(songs.first);
  }

  Future<void> addInitial() async {
    if (widget.initials.isEmpty) return;

    final files = widget.initials
        .where(isAudioFile)
        .map((path) => XFile(path))
        .toList();

    if (files.isEmpty) return;

    final res = await ref.read(libraryServiceProvider).getSongFromFile(files);

    if (res.isEmpty) return;

    await ref.read(musicServiceProvider.notifier).playTrack(res.first);
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(themeProvider);
    return settingsAsync.when(
      loading: () => MaterialApp(
        theme: AppThemes.light,
        darkTheme: AppThemes.dark,
        themeMode: ThemeMode.dark,
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (error, stack) => MaterialApp(
        theme: AppThemes.light,
        darkTheme: AppThemes.dark,
        home: const AppView(),
      ),
      data: (settings) {
        return MaterialApp(
          navigatorKey: router.navigatorKey,
          theme: AppThemes.light,
          darkTheme: AppThemes.dark,
          themeMode: settings.theme == 'dark'
              ? ThemeMode.dark
              : settings.theme == 'light'
              ? ThemeMode.light
              : ThemeMode.system,
          home: const AppView(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
