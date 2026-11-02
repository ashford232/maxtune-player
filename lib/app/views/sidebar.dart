import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxtune_player/app/services/app_providers.dart';
import 'package:maxtune_player/app/views/view.dart';

class Sidebar extends ConsumerStatefulWidget {
  final bool? floating;
  const Sidebar({super.key, this.floating});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SidebarState();
}

class _SidebarState extends ConsumerState<Sidebar> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isCompact = size.width < 750;
    final isSmall = size.width < 600;

    final nav = ref.watch(navProvider);
    final navNotifier = ref.watch(navProvider.notifier);
    final index = nav.index;
    final currentItem = navItems[index];
    final theme = Theme.of(context);
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.ease,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
        child: SizedBox(
          width: widget.floating == true
              ? 250
              : isSmall
              ? 0
              : isCompact
              ? 43
              : 250,
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  separatorBuilder: (context, index) => SizedBox(height: 3),
                  itemBuilder: (context, index) {
                    final item = navItems[index];
                    final isCurrent = item.id == currentItem.id;
                    return InkWell(
                      borderRadius: .circular(3),

                      onTap: () {
                        navNotifier.change(item.id);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4,
                        ),

                        decoration: BoxDecoration(
                          borderRadius: .circular(3),
                          color: isCurrent
                              ? theme.colorScheme.onSurface.withValues(
                                  alpha: 0.1,
                                )
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: widget.floating == true
                              ? .start
                              : isCompact
                              ? .center
                              : .start,
                          crossAxisAlignment: widget.floating == true
                              ? .start
                              : isCompact
                              ? .center
                              : .start,
                          children: [
                            Icon(
                              item.icon,
                              size: widget.floating == true
                                  ? null
                                  : isCompact
                                  ? 24
                                  : null,
                              fontWeight: .w100,
                            ),
                            if (!isSmall && !isCompact ||
                                widget.floating == true) ...[
                              const SizedBox(width: 10),
                              Text(item.name, style: TextStyle(fontSize: 17)),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                  itemCount: navItems.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
