import 'package:app/presentation/components/image/user_icon.dart';
import 'package:app/presentation/providers/users/all_users_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final posProvider = StateProvider((ref) => 0.0);

class NewScreen extends ConsumerWidget {
  const NewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users =
        ref.read(allUsersNotifierProvider).asData!.value.values.toList();
    final len = users.length;
    ScrollController scrollController;

    scrollController = ScrollController();
    scrollController.addListener(() {
      final currentPosition = scrollController.position.pixels;
      ref.read(posProvider.notifier).state = currentPosition;
    });
    final pos = ref.watch(posProvider);
    const height = 100.0;
    const focusedHeight = 180.0;
    const padding = 8.0;
    return Scaffold(
      appBar: AppBar(
        title: Text(pos.toString()),
      ),
      body: ListView.builder(
        itemCount: 50,
        controller: scrollController,
        itemBuilder: (context, index) {
          final isFocused = (index * (height + padding * 2) - 240 - pos).abs() <
              (height / 2 + padding);
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: AnimatedContainer(
                height: isFocused ? focusedHeight : height,
                width: isFocused ? focusedHeight : height,
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeInOutQuint,
                child: UserIcon(
                  user: users[index % len],
                  width: isFocused ? focusedHeight : height,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
