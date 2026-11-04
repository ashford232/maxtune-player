import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecentlyPlayedSongs extends ConsumerStatefulWidget {
  const RecentlyPlayedSongs({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AllSongsState();
}

class _AllSongsState extends ConsumerState<RecentlyPlayedSongs> {

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}