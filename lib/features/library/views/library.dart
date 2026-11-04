import 'package:flutter/material.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:lite_router/lite_router.dart';
import 'package:maxtune_player/features/library/views/all_songs.dart';
import 'package:maxtune_player/features/library/views/favorite_songs.dart';
import 'package:maxtune_player/features/library/views/recently_played.dart';

class LibraryView extends StatefulWidget {
  const LibraryView({super.key});

  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView> {
  final List<LibraryFeature> _libraryFeatures = [
    LibraryFeature(
      name: "All Songs",
      icon: HugeIconsStroke.musicNote01,
      widget: const AllSongs(),
    ),
    LibraryFeature(
      name: "Recently Played",
      icon: HugeIconsStroke.clock02,
      widget: const RecentlyPlayedSongs(),
    ),
    LibraryFeature(
      name: "Favorites",
      icon: HugeIconsStroke.favourite, // or heart
      widget: const FavoriteSongs(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.0,
          ),
          itemCount: _libraryFeatures.length,
          itemBuilder: (context, index) {
            final item = _libraryFeatures[index];

            return Material(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(4),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  context.push(item.widget);
                },
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item.icon, size: 40),
                      const SizedBox(height: 8),
                      Text(
                        item.name,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class LibraryFeature {
  final String name;
  final IconData icon;
  final Widget widget;

  LibraryFeature({
    required this.name,
    required this.icon,
    required this.widget,
  });
}
