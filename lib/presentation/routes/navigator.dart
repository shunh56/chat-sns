import 'package:app/domain/entity/posts/post.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/routes/page_transition.dart';
import 'package:app/presentation/pages/chat/sub_pages/chatting_screen/chatting_screen.dart';
import 'package:app/presentation/pages/profile/profile_page.dart';
import 'package:app/presentation/pages/user/user_profile_page/user_profile_page.dart';
import 'package:app/presentation/pages/posts/timeline_page/post_screen.dart';
import 'package:app/data/datasource/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/users/all_users_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final navigationRouterProvider =
    Provider.family<NavigationRouter, BuildContext>(
  (ref, context) => NavigationRouter(
    ref,
    context,
  ),
);

class NavigationRouter {
  final Ref ref;
  final BuildContext context;
  NavigationRouter(this.ref, this.context);

  goToProfile(UserAccount user, {bool replace = false}) async {
    final myId = ref.watch(authProvider).currentUser!.uid;
    await ref
        .read(allUsersNotifierProvider.notifier)
        .updateUserAccount(user.userId);
    if (user.userId == myId) {
      Navigator.push(
        context,
        PageTransitionMethods.slideUp(
          const ProfileScreen(
            canPop: true,
          ),
        ),
      );
    } else {
      if (replace) {
        Navigator.pushReplacement(context,
            PageTransitionMethods.slideUp(UserProfileScreen(user: user)));
      } else {
        Navigator.push(context,
            PageTransitionMethods.slideUp(UserProfileScreen(user: user)));
      }
    }
  }

  goToChat(UserAccount? user, {bool replace = false, String? userId}) {
    userId = userId ?? user?.userId;
    if (replace) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChattingScreen(userId: userId!),
          settings: const RouteSettings(name: '/chatting_screen'),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChattingScreen(userId: userId!),
          settings: const RouteSettings(name: '/chatting_screen'),
        ),
      );
    }
  }

  goToPost(Post post, UserAccount user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PostScreen(
          postRef: post,
          user: user,
        ),
      ),
    );
  }
}
