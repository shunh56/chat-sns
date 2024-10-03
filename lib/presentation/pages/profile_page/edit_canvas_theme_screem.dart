import 'package:app/core/extenstions/timestamp_extenstion.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/bottom_sheets/profile_bottomsheet.dart';
import 'package:app/presentation/pages/profile_page/profile_page.dart';
import 'package:app/presentation/providers/provider/users/my_user_account_notifier.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class EditCanvasThemeScreen extends ConsumerWidget {
  const EditCanvasThemeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const imageHeight = 80.0;
    final themeSize = ref.watch(themeSizeProvider(context));
    final notifier = ref.read(myAccountNotifierProvider.notifier);
    final asyncValue = ref.watch(myAccountNotifierProvider);
    final canvasTheme = ref.watch(canvasThemeProvider);
    final stateNotifier = ref.read(canvasThemeProvider.notifier);
    final listView = asyncValue.when(
      data: (me) {
        return Padding(
          padding:
              EdgeInsets.symmetric(horizontal: themeSize.horizontalPadding),
          child: ListView(
            padding: const EdgeInsets.only(top: 12),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //profile
                  const Text(
                    "キャンバス",
                  ),
                  const Gap(12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: canvasTheme.bgColor,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          me.name,
                          style: TextStyle(
                            fontSize: 24,
                            color: canvasTheme.profileTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "${me.createdAt.toDateStr}〜",
                          style: TextStyle(
                            color: canvasTheme.profileSecondaryTextColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ThemeColor.beige,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                "背景色",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                ProfileBottomSheet(ref).openColorSheet(
                                    context, canvasTheme, "bgColor");
                              },
                              child: RainbowRing(color: canvasTheme.bgColor),
                            ),
                          ],
                        ),
                        Divider(
                          color: Colors.black.withOpacity(0.5),
                        ),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                "テキスト",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                ProfileBottomSheet(ref).openColorSheet(
                                    context, canvasTheme, "profileTextColor");
                              },
                              child: RainbowRing(
                                  color: canvasTheme.profileTextColor),
                            ),
                          ],
                        ),
                        Divider(
                          color: Colors.black.withOpacity(0.5),
                        ),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                "サブテキスト",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                ProfileBottomSheet(ref).openColorSheet(context,
                                    canvasTheme, "profileSecondaryTextColor");
                              },
                              child: RainbowRing(
                                  color: canvasTheme.profileSecondaryTextColor),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const Gap(24),
                  //box
                  const Text(
                    "ボックス",
                  ),
                  const Gap(12),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24 - canvasTheme.boxWidth),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: canvasTheme.bgColor,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          canvasTheme.boxRadius,
                        ),
                        border: Border.all(
                          color: Colors.black.withOpacity(0.1),
                          width: canvasTheme.boxWidth,
                        ),
                        color: canvasTheme.boxBgColor,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "自己紹介",
                            style: TextStyle(
                              fontSize: 16,
                              color: canvasTheme.boxTextColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            me.aboutMe,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              color: canvasTheme.boxSecondaryTextColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Gap(12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ThemeColor.beige,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                "背景色",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                ProfileBottomSheet(ref).openColorSheet(
                                    context, canvasTheme, "boxBgColor");
                              },
                              child: RainbowRing(color: canvasTheme.boxBgColor),
                            ),
                          ],
                        ),
                        Divider(
                          color: Colors.black.withOpacity(0.5),
                        ),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                "テキスト",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                ProfileBottomSheet(ref).openColorSheet(
                                    context, canvasTheme, "boxTextColor");
                              },
                              child:
                                  RainbowRing(color: canvasTheme.boxTextColor),
                            ),
                          ],
                        ),
                        Divider(
                          color: Colors.black.withOpacity(0.5),
                        ),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                "サブテキスト",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                ProfileBottomSheet(ref).openColorSheet(context,
                                    canvasTheme, "boxSecondaryTextColor");
                              },
                              child: RainbowRing(
                                  color: canvasTheme.boxSecondaryTextColor),
                            ),
                          ],
                        ),
                        Divider(
                          color: Colors.black.withOpacity(0.5),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Text(
                                    "枠線",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Gap(8),
                                  Text(
                                    canvasTheme.boxWidth.toString(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (canvasTheme.boxWidth != 0.0) {
                                  stateNotifier.state = canvasTheme.copyWith(
                                    boxWidth: canvasTheme.boxWidth - 0.5,
                                  );
                                }
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(4),
                                    bottomLeft: Radius.circular(4),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.remove,
                                ),
                              ),
                            ),
                            const Gap(2),
                            GestureDetector(
                              onTap: () {
                                if (canvasTheme.boxWidth < 16.0) {
                                  stateNotifier.state = canvasTheme.copyWith(
                                    boxWidth: canvasTheme.boxWidth + 0.5,
                                  );
                                }
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(4),
                                    bottomRight: Radius.circular(4),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.add,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          color: Colors.black.withOpacity(0.5),
                        ),
                        Row(
                          children: [
                            Row(
                              children: [
                                const Text(
                                  "角丸",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Gap(8),
                                SizedBox(
                                  width: 40,
                                  child: Text(
                                    canvasTheme.boxRadius.toString(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Slider(
                                min: 0,
                                max: 24,
                                value: canvasTheme.boxRadius,
                                thumbColor: Colors.white,
                                activeColor: Colors.blue,
                                inactiveColor: Colors.white.withOpacity(0.3),
                                onChanged: (value) {
                                  final fixedValue = (value * 10).round() / 10;
                                  stateNotifier.state = canvasTheme.copyWith(
                                      boxRadius: fixedValue);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Gap(24),
                  //icon

                  const Text(
                    "アイコン",
                  ),
                  const Gap(12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: canvasTheme.bgColor,
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(canvasTheme.iconStrokeWidth),
                          decoration: BoxDecoration(
                            gradient: !canvasTheme.iconHideBorder
                                ? LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      canvasTheme.iconGradientStartColor,
                                      canvasTheme.iconGradientEndColor,
                                    ],
                                  )
                                : null,
                            borderRadius: BorderRadius.circular(
                              canvasTheme.iconRadius + 12,
                            ),
                          ),
                          child: Container(
                            padding: EdgeInsets.all(
                                12 - canvasTheme.iconStrokeWidth),
                            decoration: BoxDecoration(
                              color: canvasTheme.bgColor,
                              borderRadius: BorderRadius.circular(
                                canvasTheme.iconRadius +
                                    12 -
                                    canvasTheme.iconStrokeWidth,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(canvasTheme.iconRadius),
                              child: Container(
                                color: ThemeColor.accent,
                                height: imageHeight,
                                width: imageHeight,
                                child: me.imageUrl != null
                                    ? CachedNetworkImage(
                                        imageUrl: me.imageUrl!,
                                        fadeInDuration:
                                            const Duration(milliseconds: 120),
                                        imageBuilder:
                                            (context, imageProvider) =>
                                                Container(
                                          height: imageHeight,
                                          width: imageHeight,
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        placeholder: (context, url) =>
                                            const SizedBox(),
                                        errorWidget: (context, url, error) =>
                                            const SizedBox(),
                                      )
                                    : const Icon(
                                        Icons.person_outline,
                                        size: imageHeight * 0.8,
                                        color: ThemeColor.stroke,
                                      ),
                              ),
                            ),
                          ),
                        ),
                        const Gap(8),
                        Text(
                          !canvasTheme.iconHideLevel ? "LEVEL 1" : "",
                          style: TextStyle(
                            color: canvasTheme.profileTextColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ThemeColor.beige,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                "スタート",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                ProfileBottomSheet(ref).openColorSheet(context,
                                    canvasTheme, "iconGradientStartColor");
                              },
                              child: RainbowRing(
                                  color: canvasTheme.iconGradientStartColor),
                            ),
                          ],
                        ),
                        Divider(
                          color: Colors.black.withOpacity(0.5),
                        ),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                "エンド",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                ProfileBottomSheet(ref).openColorSheet(context,
                                    canvasTheme, "iconGradientEndColor");
                              },
                              child: RainbowRing(
                                color: canvasTheme.iconGradientEndColor,
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          color: Colors.black.withOpacity(0.5),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Text(
                                    "枠線",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Gap(8),
                                  Text(
                                    canvasTheme.iconStrokeWidth.toString(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (canvasTheme.iconStrokeWidth != 0.0) {
                                  stateNotifier.state = canvasTheme.copyWith(
                                    iconStrokeWidth:
                                        canvasTheme.iconStrokeWidth - 0.5,
                                  );
                                }
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(4),
                                    bottomLeft: Radius.circular(4),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.remove,
                                ),
                              ),
                            ),
                            const Gap(2),
                            GestureDetector(
                              onTap: () {
                                if (canvasTheme.iconStrokeWidth < 12.0) {
                                  stateNotifier.state = canvasTheme.copyWith(
                                    iconStrokeWidth:
                                        canvasTheme.iconStrokeWidth + 0.5,
                                  );
                                }
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(4),
                                    bottomRight: Radius.circular(4),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.add,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          color: Colors.black.withOpacity(0.5),
                        ),
                        Row(
                          children: [
                            Row(
                              children: [
                                const Text(
                                  "角丸",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Gap(8),
                                SizedBox(
                                  width: 40,
                                  child: Text(
                                    canvasTheme.iconRadius.toString(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Slider(
                                min: 0,
                                max: 40,
                                value: canvasTheme.iconRadius,
                                thumbColor: Colors.white,
                                activeColor: Colors.blue,
                                inactiveColor: Colors.white.withOpacity(0.3),
                                onChanged: (value) {
                                  final fixedValue = (value * 10).round() / 10;
                                  stateNotifier.state = canvasTheme.copyWith(
                                      iconRadius: fixedValue);
                                },
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          color: Colors.black.withOpacity(0.5),
                        ),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                "枠線を隠す",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            CupertinoSwitch(
                              trackColor: Colors.black.withOpacity(0.3),
                              value: canvasTheme.iconHideBorder,
                              onChanged: (val) {
                                stateNotifier.state = canvasTheme.copyWith(
                                  iconHideBorder: val,
                                );
                              },
                            ),
                          ],
                        ),
                        Divider(
                          color: Colors.black.withOpacity(0.5),
                        ),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                "レベルを隠す",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            CupertinoSwitch(
                              trackColor: Colors.black.withOpacity(0.3),
                              value: canvasTheme.iconHideLevel,
                              onChanged: (val) {
                                stateNotifier.state = canvasTheme.copyWith(
                                  iconHideLevel: val,
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Gap(24),
                ],
              ),
            ],
          ),
        );
      },
      error: (e, s) => const SizedBox(),
      loading: () => const SizedBox(),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "キャンバスを編集",
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              notifier.changeColor(canvasTheme);
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Colors.blue,
              ),
              child: const Text(
                "保存する",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Gap(themeSize.horizontalPadding),
        ],
      ),
      body: listView,
    );
  }
}

class RainbowRing extends StatelessWidget {
  const RainbowRing({
    super.key,
    required this.color,
  });

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF0064),
              Color(0xFFFF7600),
              Color(0xFFFFD500),
              Color(0xFF8CFE00),
              Color(0xFF00E86C),
              Color(0xFF00F4F2),
              Color(0xFF00CCFF),
              Color(0xFF70A2FF),
              Color(0xFFA96CFF),
            ],
          ).createShader(
            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
          ),
          child: const CircleAvatar(
            radius: 12,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: ThemeColor.beige,
          ),
          child: CircleAvatar(
            radius: 8,
            backgroundColor: color,
          ),
        ),
      ],
    );
  }
}
