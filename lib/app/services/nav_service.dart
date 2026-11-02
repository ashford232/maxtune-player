import 'package:flutter_riverpod/flutter_riverpod.dart';

class NavigationService extends Notifier<NavigationState> {
  @override
  NavigationState build() {
    return NavigationState(index: 0);
  }

  void change(int val) {
    state = state.copyWith(index: val);
  }
}

class NavigationState {
  final int index;

  NavigationState({required this.index});

  NavigationState copyWith({int? index}) {
    return NavigationState(index: index ?? this.index);
  }
}
