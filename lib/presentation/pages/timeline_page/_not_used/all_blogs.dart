/*import 'package:app/presentation/pages/timeline_page/widget/blog_widget.dart';
import 'package:app/presentation/providers/provider/posts/all_blogs.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//keepAlive => stateful widget

class AllBlogsThread extends ConsumerStatefulWidget {
  const AllBlogsThread({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AllBlogsThreadState();
}

class _AllBlogsThreadState extends ConsumerState<AllBlogsThread>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    //final themeSize = ref.watch(themeSizeProvider(context));
    final blogList = ref.watch(allBlogsNotiferProvider);
    return blogList.when(
      data: (list) {
        return RefreshIndicator(
          onRefresh: () async {
            return await ref.read(allBlogsNotiferProvider.notifier).refresh();
          },
          child: ListView(
            padding: const EdgeInsets.only(top: 8),
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 120),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final blog = list[index];
                  final user = ref
                      .read(allUsersNotifierProvider)
                      .asData!
                      .value[blog.userId]!;

                  return BlogWidget(blog: blog, user: user);
                },
              ),
            ],
          ),
        );
      },
      error: (e, s) {
        return const SizedBox();
      },
      loading: () {
        return const SizedBox();
      },
    );
  }
}
 */