import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_router/lite_router.dart';
import 'package:maxtune_player/app/views/view.dart';
import 'package:maxtune_player/shared/themes/app_themes.dart';
import 'package:mpv_audio_kit/mpv_audio_kit.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MpvAudioKit.ensureInitialized();
  runApp(const ProviderScope(child: MaxTunePlayer()));
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
  const MaxTunePlayer({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MaxTunePlayerState();
}

class _MaxTunePlayerState extends ConsumerState<MaxTunePlayer> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: router.navigatorKey,

      theme: AppThemes.light,
      darkTheme: AppThemes.dark,
      themeMode: .light,
      home: AppView(),
      debugShowCheckedModeBanner: false,
    );
  }
}
