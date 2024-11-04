// ignore: dangling_library_doc_comments
/**import 'package:app/core/extenstions/timestamp_extenstion.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/image/image.dart';
import 'package:app/presentation/navigation/navigator.dart';
import 'package:app/presentation/pages/chat_screen/sub_screens/chatting_screen/chatting_screen.dart';
import 'package:app/presentation/phase_01/footprints_screen.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:app/presentation/providers/provider/users/footprints_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

class FootprintedsScreen extends ConsumerWidget {
  const FootprintedsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final footprints =
        ref.watch(footprintsListNotifierProvider).asData?.value ?? [];
    return Scaffold(
      appBar: AppBar(
        title: const Text("足あと"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: ThemeColor.beige,
            child: InkWell(
              splashColor: ThemeColor.highlight,
              highlightColor: ThemeColor.beige.withOpacity(0.3),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FootprintsScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: SvgPicture.asset(
                        "assets/images/icons/send.svg",
                        color: ThemeColor.button,
                      ),
                    ),
                    const Gap(12),
                    const Text(
                      "自分がつけた足あと",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                    footprints.isNotEmpty
                        ? Text(
                            "${footprints.length}",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : const SizedBox(),
                    const Gap(12),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: ThemeColor.button,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.read(footprintedsListNotifierProvider.notifier).refresh();
              },
              child: footprintedsListView(ref),
            ),
          ),
        ],
      ),
    );
  }

  Widget footprintedsListView(WidgetRef ref) {
    final asyncValue = ref.watch(footprintedsListNotifierProvider);
    return asyncValue.when(
      data: (footprinteds) {
        return ListView(
          children: [
            const Gap(12),
            const Padding(
              padding: EdgeInsets.only(left: 12),
              child: Text(
                "足あと",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ThemeColor.text,
                ),
              ),
            ),
            const Gap(6),
            footprinteds.isEmpty
                ? const SizedBox(
                    height: 300,
                    child: Center(
                      child: Text("ユーザーからの足あとありません。"),
                    ),
                  )
                : ListView.builder(
                    //padding: EdgeInsets.symmetric(horizontal: 12),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: footprinteds.length,
                    itemBuilder: (context, index) {
                      final footprint = footprinteds[index];
                      final userId = footprint.userId;
                      final user = ref
                          .read(allUsersNotifierProvider)
                          .asData!
                          .value[userId]!;
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: ThemeColor.highlight,
                          highlightColor: ThemeColor.beige.withOpacity(0.3),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChattingScreen(userId: user.userId),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    
                                    ref
                                        .read(navigationRouterProvider(context))
                                        .goToProfile(user);
                                  },
                                  child: CachedImage.userIcon(
                                      user.imageUrl, user.username, 24),
                                ),
                                const Gap(12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            user.username,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: ThemeColor.text,
                                            ),
                                          ),
                                          Text(
                                            footprint.updatedAt.xxAgo,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: ThemeColor.text,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        user.aboutMe,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: ThemeColor.text,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        );
      },
      error: (e, s) => const SizedBox(),
      loading: () => const SizedBox(),
    );
  }
}
 */