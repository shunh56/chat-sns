/*import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/image/image.dart';
import 'package:app/presentation/pages/sub_pages/user_profile_page/user_profile_page.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/presentation/providers/provider/users/hima_users_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gap/gap.dart';

class Tile extends StatelessWidget {
  const Tile({
    super.key,
    required this.index,
    this.extent,
    this.backgroundColor,
    this.bottomSpace,
  });

  final int index;
  final double? extent;
  final double? bottomSpace;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      color: backgroundColor ?? ThemeColor.beige,
      height: extent,
      child: Center(
        child: CircleAvatar(
          minRadius: 20,
          maxRadius: 20,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          child: Text('$index', style: const TextStyle(fontSize: 20)),
        ),
      ),
    );

    if (bottomSpace == null) {
      return child;
    }

    return Column(
      children: [
        Expanded(child: child),
        Container(
          height: bottomSpace,
          color: Colors.green,
        )
      ],
    );
  }
}

class HimaUsersScreen extends ConsumerWidget {
  const HimaUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final himaUsersList = ref.watch(himaUserIdListNotifierProvider);

    final listView = himaUsersList.when(
      data: (list) {
        return MasonryGridView.count(
          itemCount: list.length,
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
          itemBuilder: (context, index) {
            final user =
                ref.read(allUsersNotifierProvider).asData!.value[list[index]]!;

            return GestureDetector(
              onTap: () {
               gotoprofile
              },
              child: Container(
                margin: EdgeInsets.only(
                  top: index == 1 ? 48 : 0,
                ),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ThemeColor.beige,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    width: 1.2,
                    color: ThemeColor.highlight.withOpacity(0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ThemeColor.highlight.withOpacity(0.5),
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                      spreadRadius: 0,
                    )
                  ],
                ),
                child: Column(
                  children: [
                    CachedImage.userIcon(
                      user.imageUrl,
                      user.username,
                      40,
                    ),
                    const Gap(12),
                    Text(
                      user.username,
                      style: const TextStyle(
                        fontSize: 18,
                        color: ThemeColor.headline,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(4),
                    Text(
                      user.aboutMe ?? "",
                      style: const TextStyle(
                        fontSize: 14,
                        color: ThemeColor.button,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      error: (e, s) => const SizedBox(),
      loading: () => const SizedBox(),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("HimaUsers"),
      ),
      body: SafeArea(child: listView),
    );
  }
}
 */