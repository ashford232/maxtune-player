import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:maxtune_player/app/services/app_providers.dart';
import 'package:maxtune_player/app/views/controls.dart';
import 'package:maxtune_player/features/Settings/settings.dart';
import 'package:maxtune_player/features/home/home.dart';
import 'package:maxtune_player/app/views/sidebar.dart';
import 'package:maxtune_player/features/library/services/library_provider.dart';
import 'package:maxtune_player/features/library/views/library.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

class AppView extends ConsumerStatefulWidget {
  const AppView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ViewState();
}

class _ViewState extends ConsumerState<AppView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isDraggingOver = false;

  // Handle incoming dropped files
  Future<void> _handleDrop(PerformDropEvent event) async {
    // Access the dropped items via event.session.items
    final items = event.session.items;

    for (final item in items) {
      final reader = item.dataReader;
      if (reader != null && reader.canProvide(Formats.fileUri)) {
        reader.getValue(Formats.fileUri, (uri) async {
          if (uri != null) {
            final filePath = uri.toFilePath();

            if (isAudioFile(filePath)) {
              final res = await ref
                  .read(libraryServiceProvider)
                  .getSongFromFile([XFile(filePath)]);

              if (res.isNotEmpty) {
                await ref
                    .read(musicServiceProvider.notifier)
                    .playTrack(res.first);
              }
            }
          }
        });
      }
    }
  }

 

  @override
  Widget build(BuildContext context) {
    final nav = ref.watch(navProvider);
    final index = nav.index;
    final item = navItems[index];
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 600;
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      drawer: Container(
        color: theme.colorScheme.surface,
        child: const Sidebar(floating: true),
      ),
      backgroundColor: theme.colorScheme.surfaceContainer,
      // Wrap your main body inside a DropRegion to listen to file drops from the OS
      body: DropRegion(
        formats: [Formats.fileUri],
        hitTestBehavior: HitTestBehavior.opaque,
        onDropEnter: (event) {
          setState(() {
            _isDraggingOver = true;
          });
        },
        onDropLeave: (event) {
          setState(() {
            _isDraggingOver = false;
          });
        },
        onDropOver: (event) {
          // Specify that we accept copy operations for files
          return DropOperation.copy;
        },
        onPerformDrop: (event) async {
          setState(() {
            _isDraggingOver = false;
          });
          await _handleDrop(event);
        },
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (!isSmall) ...[const Sidebar(), const Divider()],
                      Expanded(
                        child: Scaffold(
                          appBar: AppBar(
                            leading: isSmall
                                ? IconButton(
                                    style: IconButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    onPressed: () {
                                      _scaffoldKey.currentState?.openDrawer();
                                    },
                                    icon: const Icon(HugeIconsStroke.menu01),
                                  )
                                : null,
                            title: Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          body: IndexedStack(
                            index: index,
                            children: navItems.map((nv) => nv.widget).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                const ControlsView(),
              ],
            ),

            if (_isDraggingOver)
              Positioned.fill(
                child: Container(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Text(
                        'Drop audio files here to add to library',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class Nav {
  final String name;
  final int id;
  final IconData icon;
  final IconData activeIcon;
  final Widget widget;

  Nav({
    required this.name,
    required this.id,
    required this.icon,
    required this.widget,
    required this.activeIcon,
  });
}

final navItems = [
  Nav(
    name: 'Now Playing',
    id: 0,
    icon: HugeIconsStroke.play,
    activeIcon: HugeIconsSolid.play,
    widget: const Home(),
  ),
  Nav(
    name: 'Library',
    id: 1,
    icon: HugeIconsStroke.folderLibrary,
    activeIcon: HugeIconsSolid.folderLibrary,
    widget: const LibraryView(),
  ),
  Nav(
    name: 'Settings',
    id: 2,
    icon: HugeIconsStroke.settings01,
    activeIcon: HugeIconsSolid.settings01,
    widget: const Settings(),
  ),
];
 bool isAudioFile(String path) {
    final ext = path.split('.').last.toLowerCase();
    return ['mp3', 'flac', 'wav', 'aac', 'm4a', 'ogg'].contains(ext);
  }