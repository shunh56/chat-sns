import 'package:app/domain/entity/posts/post.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/pages/posts/components/posts/animated_post_card.dart';
import 'package:app/presentation/providers/posts/all_posts.dart';
import 'package:app/presentation/providers/users/all_users_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EnhancedPostWidget extends ConsumerWidget {
  final Post postRef;
  final int index;

  const EnhancedPostWidget({
    super.key,
    required this.postRef,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = ref.watch(allPostsNotifierProvider).asData?.value[postRef.id];
    if (post == null) return const SizedBox();
    
    final user = ref.read(allUsersNotifierProvider).asData?.value[post.userId];
    if (user == null) return const SizedBox();
    
    if (user.accountStatus != AccountStatus.normal) return const SizedBox();
    if (post.isDeletedByUser || post.isDeletedByModerator || post.isDeletedByAdmin) {
      return const SizedBox();
    }

    return AnimatedPostCard(
      post: post,
      user: user,
      index: index,
    );
  }
}