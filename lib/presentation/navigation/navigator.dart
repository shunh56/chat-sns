import 'package:app/domain/entity/posts/current_status_post.dart';
import 'package:app/domain/entity/posts/post.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/navigation/page_transition.dart';
import 'package:app/presentation/pages/chat_screen/sub_screens/chatting_screen/chatting_screen.dart';
import 'package:app/presentation/pages/profile_page/profile_page.dart';
import 'package:app/presentation/pages/sub_pages/user_profile_page/user_profile_page.dart';
import 'package:app/presentation/pages/timeline_page/current_status_post_screen.dart';
import 'package:app/presentation/pages/timeline_page/widget/post_screen.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
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
          const ProfileScreen(),
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

  goToChat(UserAccount user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChattingScreen(userId: user.userId),
      ),
    );
  }

  goToCurrentStatusPost(CurrentStatusPost post, UserAccount user,
      {bool replace = false}) {
    if (replace) {
      Navigator.pushReplacement(
        context,
        PageTransitionMethods.slideUp(
          CurrentStatusPostScreen(
            post: post,
            user: user,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        PageTransitionMethods.slideUp(
          CurrentStatusPostScreen(
            post: post,
            user: user,
          ),
        ),
      );
    }
  }

  goToPost(Post post, UserAccount user) {
    Navigator.push(
      context,
      PageTransitionMethods.slideUp(
        PostScreen(
          postRef: post,
          user: user,
        ),
      ),
    );
  }
}
