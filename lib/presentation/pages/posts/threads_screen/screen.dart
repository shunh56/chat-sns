import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/image/image.dart';
import 'package:app/presentation/providers/threads/all_threads_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class ThreadsScreen extends ConsumerWidget {
  const ThreadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppBar(
              toolbarHeight: 30,
            ),
            const RecommendedThreadsSection(),
            const Gap(32),
            const RecentlySeenThreadsSection(),
            const Gap(32),
            const FollowingThreadsSection(),
          ],
        ),
      ),
    );
  }
}

class RecommendedThreadsSection extends ConsumerWidget {
  const RecommendedThreadsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width * 0.66;
    final height = width * 0.6;
    final asyncValue = ref.watch(allThreadsNotifierProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 12),
          child: Text(
            "人気のスレッド",
            style: TextStyle(
              color: ThemeColor.headline,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Gap(6),
        asyncValue.when(
          data: (threads) {
            return SizedBox(
              height: height,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: threads.length * 4,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemBuilder: (context, index) {
                  final thread =
                      threads.entries.toList().elementAt(index ~/ 4).value;
                  return Container(
                    width: width,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.only(
                        left: 12, right: 12, top: 12, bottom: 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: ThemeColor.beige,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CachedImage.threadIcon(thread.imageUrl, 24),
                            const Gap(12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    thread.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: ThemeColor.text,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    "${thread.postCount}件の投稿",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: ThemeColor.highlight,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: ThemeColor.button,
                              ),
                              child: const Text(
                                "フォロー",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          ],
                        ),
                        const Gap(8),
                        const Divider(
                          color: ThemeColor.highlight,
                        ),
                        const Gap(8),
                        const Text(
                          "TITLE",
                          style: TextStyle(
                            fontSize: 16,
                            color: ThemeColor.text,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Text(
                          "SUBTITLE OF THIS POST...",
                          style: TextStyle(
                            fontSize: 14,
                            color: ThemeColor.text,
                          ),
                        ),
                        const Gap(6),
                        const Row(
                          children: [
                            Icon(
                              Icons.favorite_border_rounded,
                              size: 18,
                              color: ThemeColor.highlight,
                            ),
                            Gap(6),
                            Text(
                              "12",
                              style: TextStyle(
                                fontSize: 14,
                                color: ThemeColor.highlight,
                              ),
                            ),
                            Gap(24),
                            Icon(
                              Icons.comment_outlined,
                              size: 16,
                              color: ThemeColor.highlight,
                            ),
                            Gap(6),
                            Text(
                              "12",
                              style: TextStyle(
                                fontSize: 14,
                                color: ThemeColor.highlight,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
            );
          },
          error: (e, s) => const SizedBox(),
          loading: () => const SizedBox(),
        ),
      ],
    );
  }
}

class RecentlySeenThreadsSection extends ConsumerWidget {
  const RecentlySeenThreadsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(allThreadsNotifierProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 12),
          child: Text(
            "最近見たスレッド",
            style: TextStyle(
              color: ThemeColor.headline,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Gap(6),
        asyncValue.when(
          data: (threads) {
            return SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: threads.length * 4,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemBuilder: (context, index) {
                  final thread =
                      threads.entries.toList().elementAt(index ~/ 4).value;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 140,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: ThemeColor.beige,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 140,
                              height: 60,
                              child: CachedImage.threadThumbnailImage(
                                thread.thumbnailImageUrl,
                              ),
                            ),
                            Container(
                              width: 140,
                              height: 60,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(8),
                                  bottomRight: Radius.circular(8),
                                ),
                                color: ThemeColor.beige,
                              ),
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Text(
                                    thread.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: ThemeColor.text,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      CachedImage.threadIcon(thread.imageUrl, 24),
                    ],
                  );
                },
              ),
            );
          },
          error: (e, s) => const SizedBox(),
          loading: () => const SizedBox(),
        ),
      ],
    );
  }
}

class FollowingThreadsSection extends ConsumerWidget {
  const FollowingThreadsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(allThreadsNotifierProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 12),
          child: Text(
            "フォロー中のスレッド",
            style: TextStyle(
              color: ThemeColor.headline,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Gap(6),
        asyncValue.when(
          data: (threads) {
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: threads.length * 4,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                final thread =
                    threads.entries.toList().elementAt(index ~/ 4).value;
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: const BoxDecoration(
                    color: ThemeColor.beige,
                  ),
                  child: Row(
                    children: [
                      CachedImage.threadIcon(thread.imageUrl, 24),
                      const Gap(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              thread.title,
                              style: const TextStyle(
                                fontSize: 16,
                                color: ThemeColor.text,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              "${thread.postCount}件の投稿",
                              style: const TextStyle(
                                fontSize: 12,
                                color: ThemeColor.highlight,
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: ThemeColor.button,
                        ),
                        child: const Text(
                          "フォロー",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            );
          },
          error: (e, s) => const SizedBox(),
          loading: () => const SizedBox(),
        ),
      ],
    );
  }
}
