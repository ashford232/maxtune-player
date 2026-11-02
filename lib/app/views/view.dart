import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:maxtune_player/app/services/app_providers.dart';
import 'package:maxtune_player/app/views/controls.dart';
import 'package:maxtune_player/features/Settings/settings.dart';
import 'package:maxtune_player/features/home/home.dart';
import 'package:maxtune_player/app/views/sidebar.dart';
import 'package:maxtune_player/features/library/library.dart';

class AppView extends ConsumerStatefulWidget {
  const AppView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ViewState();
}

class _ViewState extends ConsumerState<AppView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
        child: Sidebar(floating: true),
      ),
      backgroundColor: theme.colorScheme.surfaceContainer,
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                if (!isSmall) ...[Sidebar(), Divider()],

                Expanded(
                  child: Scaffold(
                    appBar: AppBar(
                      leading: isSmall
                          ? IconButton(
                              style: IconButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: .circular(4),
                                ),
                              ),
                              onPressed: () {
                                _scaffoldKey.currentState?.openDrawer();
                              },
                              icon: Icon(HugeIconsStroke.menu01),
                            )
                          : null,
                      title: Text(
                        item.name,
                        style: TextStyle(
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
          Divider(),
          ControlsView(),
        ],
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
    name: 'Home',
    id: 0,
    icon: HugeIconsStroke.home04,
    activeIcon: HugeIconsSolid.home04,
    widget: Home(),
  ),

  Nav(
    name: 'Library',
    id: 1,
    icon: HugeIconsStroke.folderLibrary,
    activeIcon: HugeIconsSolid.folderLibrary,
    widget: Library(),
  ),
  Nav(
    name: 'Playlist',
    id: 2,
    icon: HugeIconsStroke.playlist01,
    activeIcon: HugeIconsSolid.playlist01,
    widget: Settings(),
  ),
  Nav(
    name: 'Settings',
    id: 3,
    icon: HugeIconsStroke.settings01,
    activeIcon: HugeIconsSolid.settings01,
    widget: Settings(),
  ),
];
