import 'package:app/_unused/pov_screen/swipe_feed.dart';
import 'package:app/domain/entity/pov.dart';
import 'package:app/presentation/components/image/image.dart';
import 'package:app/presentation/components/user_icon.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PovsGridScreen extends ConsumerWidget {
  const PovsGridScreen({super.key, required this.povs});
  final List<Pov> povs;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(),
      body: GridView.builder(
        itemCount: povs.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemBuilder: (context, index) {
          final pov = povs[index];
          final user =
              ref.watch(allUsersNotifierProvider).asData!.value[pov.userId]!;
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    appBar: AppBar(
                      title: const Text("Focused Pov"),
                    ),
                    body: Container(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewPadding.bottom),
                      child: SwipePage(
                        list: povs.sublist(index, povs.length),
                      ),
                    ),
                  ),
                ),
              );
            },
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedImage.postImage(
                    pov.imageUrl,
                  ),
                ),
                Positioned(
                  left: 4,
                  bottom: 4,
                  child: UserIcon.circleIcon(user, radius: 18),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
