import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/image/image.dart';
import 'package:app/presentation/navigation/page_transition.dart';
import 'package:app/presentation/pages/chat_screen/chat_screen.dart';
import 'package:app/presentation/pages/profile_page/profile_page.dart';
import 'package:app/presentation/pages/threads_screen/screen.dart';
import 'package:app/presentation/pages/timeline_page/create_post_screen/create_post_screen.dart';
import 'package:app/presentation/pages/timeline_page/timeline_page.dart';
import 'package:app/presentation/providers/provider/users/my_user_account_notifier.dart';
import 'package:app/presentation/providers/state/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: ref.watch(bottomNavIndexProvider),
        children: const [
          TimelinePage(),
          ThreadsScreen(),
          Scaffold(),
          //PlaygroundScreen(),
          ChatScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: const BottomBar(),
      floatingActionButton: ref.watch(bottomNavIndexProvider) == 0
          ? FloatingActionButton(
              shape: const StadiumBorder(),
              onPressed: () {
                Navigator.push(
                  context,
                  PageTransitionMethods.slideUp(
                    const CreatePostScreen(),
                  ),
                );
              },
              backgroundColor: ThemeColor.highlight,
              child: const Icon(
                Icons.add_rounded,
                color: ThemeColor.beige,
                size: 28,
              ),
            )
          : null,
    );
  }
}

class BottomBar extends ConsumerWidget {
  const BottomBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncMe = ref.watch(myAccountNotifierProvider);
    final topIcon = asyncMe.when(
      error: (e, s) {
        return CircleAvatar(
          radius: 12,
          backgroundColor: ref.watch(bottomNavIndexProvider) == 4
              ? ThemeColor.text
              : ThemeColor.text,
        );
      },
      loading: () {
        return CircleAvatar(
          radius: 12,
          backgroundColor: ref.watch(bottomNavIndexProvider) == 4
              ? ThemeColor.text
              : ThemeColor.text,
        );
      },
      data: (me) {
        return CachedImage.userIcon(me.imageUrl, me.username, 14);
      },
    );
    return BottomNavigationBar(
      backgroundColor: ThemeColor.background,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      onTap: (value) {
        
        ref.watch(bottomNavIndexProvider.notifier).changeIndex(context, value);
      },
      items: [
        BottomNavigationBarItem(
          label: 'home',
          icon: SizedBox(
            height: 32,
            width: 32,
            child: Icon(
              Icons.home_rounded,
              color: ref.watch(bottomNavIndexProvider) == 0
                  ? ThemeColor.text
                  : ThemeColor.text,
            ),
          ),
        ),
        BottomNavigationBarItem(
          label: 'search',
          icon: SizedBox(
            height: 32,
            width: 32,
            child: Icon(
              Icons.search_outlined,
              color: ref.watch(bottomNavIndexProvider) == 1
                  ? ThemeColor.text
                  : ThemeColor.text,
            ),
          ),
        ),
        BottomNavigationBarItem(
          label: 'playground',
          icon: SizedBox(
            height: 32,
            width: 32,
            child: Icon(
              Icons.mic_rounded,
              color: ref.watch(bottomNavIndexProvider) == 2
                  ? ThemeColor.text
                  : ThemeColor.text,
            ),
          ),
        ),
        BottomNavigationBarItem(
          label: 'chat',
          icon: SizedBox(
            height: 32,
            width: 32,
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              color: ref.watch(bottomNavIndexProvider) == 3
                  ? ThemeColor.text
                  : ThemeColor.text,
            ),
          ),
        ),
        BottomNavigationBarItem(
          label: 'profile',
          icon: topIcon,
        )
      ],
    );
  }
}
