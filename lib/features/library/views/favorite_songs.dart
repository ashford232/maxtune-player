import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoriteSongs extends ConsumerStatefulWidget {
  const FavoriteSongs({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AllSongsState();
}

class _AllSongsState extends ConsumerState<FavoriteSongs> {

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}