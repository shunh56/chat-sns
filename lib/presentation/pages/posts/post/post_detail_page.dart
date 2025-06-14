// lib/presentation/pages/posts/post_screen.dart
import 'dart:math';
import 'package:app/core/extenstions/timestamp_extenstion.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/posts/post.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/bottom_sheets/post_bottomsheet.dart';
import 'package:app/presentation/components/icons.dart';
import 'package:app/presentation/components/image/user_icon.dart';
import 'package:app/presentation/pages/main_page/heart_animation_overlay.dart';
import 'package:app/presentation/pages/posts/enhanced_reaction_button.dart';
import 'package:app/presentation/pages/posts/post/components/vibe/vibe_indicator.dart';
import 'package:app/presentation/pages/posts/post/components/media/interactive_media_viewer.dart';
import 'package:app/presentation/pages/posts/post/widgets/post_card/post_card.dart';
import 'package:app/presentation/pages/posts/post/widgets/replies/reply_item.dart';
import 'package:app/presentation/pages/posts/widget/post_widget.dart';
import 'package:app/presentation/providers/posts/all_posts.dart';
import 'package:app/presentation/providers/posts/replies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'dart:ui';

final inputTextProvider = StateProvider.autoDispose((ref) => "");
final controllerProvider =
    Provider.autoDispose((ref) => TextEditingController());

class PostScreen extends HookConsumerWidget {
  const PostScreen({super.key, required this.postRef, required this.user});
  final Post postRef;
  final UserAccount user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final post = ref.watch(allPostsNotifierProvider).asData!.value[postRef.id]!;
    final controller = ref.watch(controllerProvider);

    // アニメーション用のコントローラー
    final fadeController = useAnimationController(
      duration: const Duration(milliseconds: 800),
    );

    final slideController = useAnimationController(
      duration: const Duration(milliseconds: 600),
    );

    final fadeAnimation = useMemoized(
      () => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: fadeController,
          curve: Curves.easeOut,
        ),
      ),
      [fadeController],
    );

    final slideAnimation = useMemoized(
      () => Tween<Offset>(
        begin: const Offset(0, 0.1),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: slideController,
          curve: Curves.easeOutCubic,
        ),
      ),
      [slideController],
    );

    useEffect(() {
      fadeController.forward();
      slideController.forward();
      return null;
    }, []);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A), // ダークテーマ背景
      appBar: _buildModernAppBar(context, post, textStyle),
      body: FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(
          position: slideAnimation,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(top: 12),
                  children: [
                    PostCard(
                      style: PostCardStyle.detail,
                      postRef: postRef,
                      user: user,
                    ),
                    _buildDivider(),
                    _buildPostRepliesList(context, ref, post),
                  ],
                ),
              ),
              _buildModernInputSection(
                  context, ref, post, controller, textStyle),
            ],
          ),
        ),
      ),
    );
  }

  // モダンなアプリバー
  AppBar _buildModernAppBar(
      BuildContext context, Post post, ThemeTextStyle textStyle) {
    return AppBar(
      backgroundColor: const Color(0xFF0A0A0A),
      elevation: 0,
      leading: GestureDetector(
        onTap: () {
          primaryFocus?.unfocus();
          Navigator.pop(context);
        },
        child: Container(
          margin: const EdgeInsets.all(8),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
      title: Text(
        post.title,
        style: textStyle.w700(
          fontSize: 16,
          color: Colors.white,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      titleSpacing: 8,
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          child: IconButton(
            onPressed: () {
              // シェア機能
            },
            icon: Icon(
              shareIcon,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  // モダンなディバイダー
  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.white.withOpacity(0.1),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  // モダンな入力セクション
  Widget _buildModernInputSection(
    BuildContext context,
    WidgetRef ref,
    Post post,
    TextEditingController controller,
    ThemeTextStyle textStyle,
  ) {
    return Container(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewPadding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // ユーザーアイコン
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _getVibeColor(user).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: UserIcon(
              user: user,
            ),
          ),
          const Gap(12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: 4,
                style: textStyle.w400(
                  fontSize: 14,
                  color: Colors.white,
                ),
                onChanged: (value) {
                  ref.read(inputTextProvider.notifier).state = value;
                },
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    _submitReply(ref, post, value, controller);
                  }
                },
                decoration: InputDecoration(
                  hintText: "コメントを入力...",
                  hintStyle: textStyle.w400(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                ),
              ),
            ),
          ),
          const Gap(8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: ref.watch(inputTextProvider).isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      String text = ref.read(inputTextProvider);
                      _submitReply(ref, post, text, controller);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getVibeColor(user),
                            _getVibeColor(user).withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: _getVibeColor(user).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.send_rounded,
                      color: Colors.white.withOpacity(0.3),
                      size: 20,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostRepliesList(BuildContext context, WidgetRef ref, Post post) {
    final asyncValue = ref.watch(postRepliesNotifierProvider(post.id));
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: asyncValue.when(
        data: (list) {
          if (list.isEmpty) {
            return Container(
              padding: const EdgeInsets.only(top: 120),
              child: Column(
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 48,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  const Gap(16),
                  Text(
                    'まだコメントがありません',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    '最初のコメントを投稿してみましょう！',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              final reply = list[index];
              return ReplyItem(reply: reply);
            },
          );
        },
        error: (e, s) => Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red.withOpacity(0.5),
              ),
              const Gap(16),
              Text(
                'コメントの読み込みに失敗しました',
                style: TextStyle(
                  color: Colors.red.withOpacity(0.7),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        loading: () => Container(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: CircularProgressIndicator(
              color: _getVibeColor(user),
            ),
          ),
        ),
      ),
    );
  }

  void _submitReply(
    WidgetRef ref,
    Post post,
    String text,
    TextEditingController controller,
  ) {
    ref.read(allPostsNotifierProvider.notifier).addReply(user, post, text);
    controller.clear();
    ref.read(inputTextProvider.notifier).state = "";
    primaryFocus?.unfocus();
  }

  // ヘルパーメソッド
  Color _getVibeColor(UserAccount user) {
    switch (user.name.hashCode % 4) {
      case 0:
        return const Color(0xFF6B46C1);
      case 1:
        return const Color(0xFFEA580C);
      case 2:
        return const Color(0xFF0284C7);
      case 3:
        return const Color(0xFF059669);
      default:
        return const Color(0xFF6B46C1);
    }
  }
}
