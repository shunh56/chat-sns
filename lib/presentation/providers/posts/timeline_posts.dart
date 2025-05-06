// Flutter imports:

// Package imports:
import 'package:app/domain/entity/posts/post.dart';
import 'package:app/presentation/providers/posts/all_posts.dart';
import 'package:app/presentation/providers/users/all_users_notifier.dart';
import 'package:app/domain/usecases/posts/post_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final timelinePostsNotiferProvider =
    StateNotifierProvider<PostsNotifier, AsyncValue<List<Post>>>((ref) {
  return PostsNotifier(
    ref,
    ref.watch(postUsecaseProvider),
  )..initialize();
});

/// State
class PostsNotifier extends StateNotifier<AsyncValue<List<Post>>> {
  PostsNotifier(this.ref, this.usecase) : super(const AsyncValue.loading());

  final Ref ref;
  final PostUsecase usecase;

  Future<void> initialize() async {
    final posts = await usecase.getPosts();

    await ref
        .read(allUsersNotifierProvider.notifier)
        .getUserAccounts(posts.map((post) => post.userId).toList());
    ref.read(allPostsNotifierProvider.notifier).addPosts(posts);

    state = AsyncValue.data(posts);
  }

  /*getNewPosts() async {
    final listToUpdate = state.asData!.value;
    final posts =
        await usecase.getNewPosts(listToUpdate[listToUpdate.length - 1]);
    List<Future> futures = [];
    for (var post in posts) {
      futures.add(
        ref.read(allUsersNotifierProvider).getUserFuture(post.userId),
      );
    }
    await Future.wait(futures);
    posts.sort(
      (a, b) => a.createdAt.compareTo(b.createdAt),
    );
    state = AsyncValue.data([...listToUpdate, ...posts]);
  } */
/*
  getOldPosts() async {
    final listToUpdate = state.asData!.value;
    final posts = await usecase.getOldPosts(listToUpdate[0]);
    List<Future> futures = [];
    for (var post in posts) {
      futures.add(
        ref.read(allUsersNotifierProvider).getUserFuture(post.userId),
      );
    }
    await Future.wait(futures);
    posts.sort(
      (a, b) => a.createdAt.compareTo(b.createdAt),
    );
    state = AsyncValue.data([...posts, ...listToUpdate]);
  } */

/*  update(List<Post> list) async {
    if (list[list.length - 1].userId ==
        ref.watch(authProvider).currentUser?.uid) {
      /* if (ref.read(timelineScrollController).hasClients) {
        ref.read(timelineScrollController).animateTo(
              0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
      } */
    }
    List<Post> currentList = state.asData!.value;
    for (Post post in list) {
      if (!currentList.map((e) => e.id).toList().contains(post.id)) {
        currentList.add(post);
      }
    }

    state = AsyncValue.data(currentList);
  }

  uploadReply(Post post, String text) {
    bool postFound = false;
    final form = usecase.uploadReply(
      post,
      PostState(text: text, images: []),
    );
    final listToUpdate = state.value!;
    for (var e in listToUpdate) {
      if (e.id == post.id) {
        postFound = true;
        e.replyIds.add(form.id);
      }
    }
    if (!postFound) {
      ref
          .read(userPostsNotiferProvider(post.userId).notifier)
          .uploadReply(post, form);
    }
    ref.read(allActionsNotifierProvider).saveAction(
          Action.createPostReply(
              post.id, ref.watch(authProvider).currentUser!.uid, post.userId),
        );
    state = AsyncValue.data(listToUpdate);
  }

  addReaction(Post post, String emoji) {
    final listToUpdate = state.value!;
    bool postFound = false;
    for (var e in listToUpdate) {
      if (e.id == post.id) {
        postFound = true;
        List<String> userIds = List<String>.from(e.reactions[emoji] ?? []);
        String myId = ref.watch(authProvider).currentUser!.uid;
        if (!userIds.contains(myId)) {
          userIds.add(myId);
          e.reactions[emoji] = userIds;
          usecase.updateReactions(post, e.reactions);
          state = AsyncValue.data(listToUpdate);
        }
      }
    }

    ref
        .read(userPostsNotiferProvider(post.userId).notifier)
        .addReaction(post, emoji, postFound);
    ref.read(allActionsNotifierProvider).saveAction(
          Action.createPostReaction(
              post.id, ref.watch(authProvider).currentUser!.uid, post.userId),
        );
  }

  addLike(Post reply) {
    reply.likedUserIds.add(ref.watch(authProvider).currentUser!.uid);
    usecase.updateLikedUsers(reply);
    ref.read(allActionsNotifierProvider).saveAction(
          Action.createPostLike(
              reply.id, ref.watch(authProvider).currentUser!.uid, reply.userId),
        );
  }

  removeLike(Post reply) {
    reply.likedUserIds.removeWhere(
        (element) => element == ref.watch(authProvider).currentUser!.uid);
    usecase.updateLikedUsers(reply);
  }

  removePost(Post post) {
    final listToUpdate = state.value!;
    listToUpdate.removeWhere((element) => element.id == post.id);
    state = AsyncValue.data(listToUpdate);
  }

  deletePost(Post post) {
    removePost(post);
    ref.read(userPostsNotiferProvider(post.userId).notifier).removePost(post);
    usecase.deletePost(post);
  }

 */

  // blockしたユーザーは状態管理しているから不要
  //removeUsersPosts(UserAccount user) {}
}
