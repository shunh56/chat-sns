import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/image/user_icon.dart';
import 'package:app/presentation/providers/chats/dm_overview_list.dart';
import 'package:app/presentation/providers/users/all_users_notifier.dart';
import 'package:app/presentation/routes/navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainPageDrawer extends ConsumerWidget {
  const MainPageDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dmAsyncValue = ref.watch(dmOverviewListNotifierProvider);
    return Drawer(
      width: 92,
      clipBehavior: Clip.none,
      backgroundColor: ThemeColor.accent,
      child: SafeArea(
        maintainBottomViewPadding: true,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            /*   Center(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: GestureDetector(
                    onTap: () {
                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChatScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(strokeWidth),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            canvasTheme.iconGradientStartColor,
                            canvasTheme.iconGradientEndColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(
                          radius + padding + strokeWidth,
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(8 - strokeWidth),
                        decoration: BoxDecoration(
                          color: ThemeColor.background,
                          borderRadius: BorderRadius.circular(
                            radius + padding,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(radius),
                          child: Container(
                            height: imageHeight,
                            width: imageHeight,
                            color: Colors.white.withOpacity(0.1),
                            child: Center(
                              child: SvgPicture.asset(
                                "assets/images/icons/chat.svg",
                                height: imageHeight * 2 / 3,
                                width: imageHeight * 2 / 3,
                                color: ThemeColor.icon,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
             */
            dmAsyncValue.when(
              data: (list) {
                if (list.isEmpty) {
                  return const SizedBox();
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final overview = list[index];
                    final user = ref
                        .read(allUsersNotifierProvider)
                        .asData!
                        .value[overview.userId]!;

                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      splashColor: ThemeColor.accent,
                      highlightColor: ThemeColor.white.withOpacity(0.1),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              ref
                                  .read(navigationRouterProvider(context))
                                  .goToChat(user);
                            },
                            onLongPress: () {
                              ref
                                  .read(navigationRouterProvider(context))
                                  .goToChat(user);
                            },
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: UserIcon(
                                    user: user,
                                  ),
                                ),
                                if (overview.isNotSeen)
                                  const Positioned(
                                    top: 4,
                                    right: 4,
                                    child: CircleAvatar(
                                      radius: 6,
                                      backgroundColor: Colors.cyan,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              error: (e, s) => const SizedBox(),
              loading: () => const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
