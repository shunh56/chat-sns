import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/routes/page_transition.dart';
import 'package:app/presentation/pages/profile/subpages/edit_bio_screen.dart';
import 'package:app/presentation/pages/profile/profile_page.dart';
import 'package:app/presentation/pages/settings/settings_screen.dart';
import 'package:app/presentation/providers/shared/users/my_user_account_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class ProfileBottomSheet {
  ProfileBottomSheet(this.context);
  final BuildContext context;
  openBottomSheet(UserAccount user) {
    //final me = ref.read(myAccountNotifierProvider).asData!.value;

    showModalBottomSheet(
      backgroundColor: ThemeColor.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(36),
      ),
      context: context,
      builder: (context) {
        return Consumer(builder: (context, ref, child) {
          final themeSize = ref.watch(themeSizeProvider(context));
          final textStyle = ThemeTextStyle(themeSize: themeSize);
          return Container(
            padding: EdgeInsets.only(
              top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 36,
              left: themeSize.horizontalPadding,
              right: themeSize.horizontalPadding,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                //ios design
                Container(
                  height: 4,
                  width: MediaQuery.sizeOf(context).width / 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),

/*
 const Gap(24),
                Container(
                  decoration: BoxDecoration(
                    color: ThemeColor.stroke,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QrCodeScreen(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "プロフィールをシェア",
                            style: textStyle.w600(
                              fontSize: 14,
                            ),
                          ),
                          Icon(
                            shareIcon,
                            color: ThemeColor.icon,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
 */
                const Gap(24),
                Container(
                  decoration: BoxDecoration(
                    color: ThemeColor.stroke,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          final me = ref
                              .watch(myAccountNotifierProvider)
                              .asData!
                              .value;
                          ref.read(nameStateProvider.notifier).state = me.name;
                          ref.read(usernameStateProvider.notifier).state =
                              me.username;
                          ref.read(bioStateProvider.notifier).state = me.bio;
                          ref.read(aboutMeStateProvider.notifier).state =
                              me.aboutMe;
                          ref.read(linksStateProvider.notifier).state =
                              me.links;
                          Navigator.pushReplacement(
                            context,
                            PageTransitionMethods.slideUp(
                              const EditProfileScreens(),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "プロフィールを編集",
                                style: textStyle.w600(
                                  fontSize: 14,
                                ),
                              ),
                              const Icon(
                                Icons.edit_rounded,
                                color: ThemeColor.icon,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Divider(
                        height: 0,
                        thickness: 0.4,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                              //   settings: const RouteSettings(
                              // name: "settings_page",
                              //   ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "設定画面",
                                style: textStyle.w600(
                                  fontSize: 14,
                                ),
                              ),
                              const Icon(
                                Icons.settings_outlined,
                                color: ThemeColor.icon,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  List<Color> colorPalette = [
    // Red
    const Color.fromARGB(255, 69, 10, 10), // Red 950
    const Color.fromARGB(255, 127, 29, 29), // Red 900
    const Color.fromARGB(255, 153, 27, 27), // Red 800
    const Color.fromARGB(255, 185, 28, 28), // Red 700
    const Color.fromARGB(255, 220, 38, 38), // Red 600
    const Color.fromARGB(255, 239, 68, 68), // Red 500
    const Color.fromARGB(255, 248, 113, 113), // Red 400
    const Color.fromARGB(255, 252, 165, 165), // Red 300
    const Color.fromARGB(255, 254, 202, 202), // Red 200
    const Color.fromARGB(255, 254, 226, 226), // Red 100
    const Color.fromARGB(255, 254, 242, 242), // Red 50

    // Orange
    const Color.fromARGB(255, 67, 20, 7), // Orange 950
    const Color.fromARGB(255, 124, 45, 18), // Orange 900
    const Color.fromARGB(255, 154, 52, 18), // Orange 800
    const Color.fromARGB(255, 194, 65, 12), // Orange 700
    const Color.fromARGB(255, 234, 88, 12), // Orange 600
    const Color.fromARGB(255, 249, 115, 22), // Orange 500
    const Color.fromARGB(255, 251, 146, 60), // Orange 400
    const Color.fromARGB(255, 253, 186, 116), // Orange 300
    const Color.fromARGB(255, 254, 215, 170), // Orange 200
    const Color.fromARGB(255, 255, 237, 213), // Orange 100
    const Color.fromARGB(255, 255, 247, 237), // Orange 50

    // Amber
    const Color.fromARGB(255, 69, 26, 3), // Amber 950
    const Color.fromARGB(255, 120, 53, 15), // Amber 900
    const Color.fromARGB(255, 146, 64, 14), // Amber 800
    const Color.fromARGB(255, 180, 83, 9), // Amber 700
    const Color.fromARGB(255, 217, 119, 6), // Amber 600
    const Color.fromARGB(255, 245, 158, 11), // Amber 500
    const Color.fromARGB(255, 251, 191, 36), // Amber 400
    const Color.fromARGB(255, 252, 211, 77), // Amber 300
    const Color.fromARGB(255, 253, 230, 138), // Amber 200
    const Color.fromARGB(255, 254, 243, 199), // Amber 100
    const Color.fromARGB(255, 255, 251, 235), // Amber 50

    // Yellow
    const Color.fromARGB(255, 66, 32, 6), // Yellow 950
    const Color.fromARGB(255, 113, 63, 18), // Yellow 900
    const Color.fromARGB(255, 133, 77, 14), // Yellow 800
    const Color.fromARGB(255, 161, 98, 7), // Yellow 700
    const Color.fromARGB(255, 202, 138, 4), // Yellow 600
    const Color.fromARGB(255, 234, 179, 8), // Yellow 500
    const Color.fromARGB(255, 250, 204, 21), // Yellow 400
    const Color.fromARGB(255, 253, 224, 71), // Yellow 300
    const Color.fromARGB(255, 254, 240, 138), // Yellow 200
    const Color.fromARGB(255, 254, 249, 195), // Yellow 100
    const Color.fromARGB(255, 254, 252, 232), // Yellow 50

    // Lime
    const Color.fromARGB(255, 26, 46, 5), // Lime 950
    const Color.fromARGB(255, 54, 83, 20), // Lime 900
    const Color.fromARGB(255, 63, 98, 18), // Lime 800
    const Color.fromARGB(255, 77, 124, 15), // Lime 700
    const Color.fromARGB(255, 101, 163, 13), // Lime 600
    const Color.fromARGB(255, 132, 204, 22), // Lime 500
    const Color.fromARGB(255, 163, 230, 53), // Lime 400
    const Color.fromARGB(255, 190, 242, 100), // Lime 300
    const Color.fromARGB(255, 217, 249, 157), // Lime 200
    const Color.fromARGB(255, 236, 252, 203), // Lime 100
    const Color.fromARGB(255, 247, 254, 231), // Lime 50

    // Green
    const Color.fromARGB(255, 5, 46, 22), // Green 950
    const Color.fromARGB(255, 20, 83, 45), // Green 900
    const Color.fromARGB(255, 22, 101, 52), // Green 800
    const Color.fromARGB(255, 21, 128, 61), // Green 700
    const Color.fromARGB(255, 22, 163, 74), // Green 600
    const Color.fromARGB(255, 34, 197, 94), // Green 500
    const Color.fromARGB(255, 74, 222, 128), // Green 400
    const Color.fromARGB(255, 134, 239, 172), // Green 300
    const Color.fromARGB(255, 187, 247, 208), // Green 200
    const Color.fromARGB(255, 220, 252, 231), // Green 100
    const Color.fromARGB(255, 240, 253, 244), // Green 50

    // Emerald
    const Color.fromARGB(255, 2, 44, 34), // Emerald 950
    const Color.fromARGB(255, 6, 78, 59), // Emerald 900
    const Color.fromARGB(255, 6, 95, 70), // Emerald 800
    const Color.fromARGB(255, 4, 120, 87), // Emerald 700
    const Color.fromARGB(255, 5, 150, 105), // Emerald 600
    const Color.fromARGB(255, 16, 185, 129), // Emerald 500
    const Color.fromARGB(255, 52, 211, 153), // Emerald 400
    const Color.fromARGB(255, 110, 231, 183), // Emerald 300
    const Color.fromARGB(255, 167, 243, 208), // Emerald 200
    const Color.fromARGB(255, 209, 250, 229), // Emerald 100
    const Color.fromARGB(255, 236, 253, 245), // Emerald 50

    // Teal
    const Color.fromARGB(255, 4, 47, 46), // Teal 950
    const Color.fromARGB(255, 19, 78, 74), // Teal 900
    const Color.fromARGB(255, 17, 94, 89), // Teal 800
    const Color.fromARGB(255, 15, 118, 110), // Teal 700
    const Color.fromARGB(255, 13, 148, 136), // Teal 600
    const Color.fromARGB(255, 20, 184, 166), // Teal 500
    const Color.fromARGB(255, 45, 212, 191), // Teal 400
    const Color.fromARGB(255, 94, 234, 212), // Teal 300
    const Color.fromARGB(255, 153, 246, 228), // Teal 200
    const Color.fromARGB(255, 204, 251, 241), // Teal 100
    const Color.fromARGB(255, 240, 253, 250), // Teal 50

    // Cyan
    const Color.fromARGB(255, 8, 51, 68), // Cyan 950
    const Color.fromARGB(255, 22, 78, 99), // Cyan 900
    const Color.fromARGB(255, 21, 94, 117), // Cyan 800
    const Color.fromARGB(255, 14, 116, 144), // Cyan 700
    const Color.fromARGB(255, 8, 145, 178), // Cyan 600
    const Color.fromARGB(255, 6, 182, 212), // Cyan 500
    const Color.fromARGB(255, 34, 211, 238), // Cyan 400
    const Color.fromARGB(255, 103, 232, 249), // Cyan 300
    const Color.fromARGB(255, 165, 243, 252), // Cyan 200
    const Color.fromARGB(255, 207, 250, 254), // Cyan 100
    const Color.fromARGB(255, 236, 254, 255), // Cyan 50

    // Sky
    const Color.fromARGB(255, 8, 47, 73), // Sky 950
    const Color.fromARGB(255, 12, 74, 110), // Sky 900
    const Color.fromARGB(255, 7, 89, 133), // Sky 800
    const Color.fromARGB(255, 3, 105, 161), // Sky 700
    const Color.fromARGB(255, 2, 132, 199), // Sky 600
    const Color.fromARGB(255, 14, 165, 233), // Sky 500
    const Color.fromARGB(255, 56, 189, 248), // Sky 400
    const Color.fromARGB(255, 125, 211, 252), // Sky 300
    const Color.fromARGB(255, 186, 230, 253), // Sky 200
    const Color.fromARGB(255, 224, 242, 254), // Sky 100
    const Color.fromARGB(255, 240, 249, 255), // Sky 50

    // Blue
    const Color.fromARGB(255, 23, 37, 84), // Blue 950
    const Color.fromARGB(255, 30, 58, 138), // Blue 900
    const Color.fromARGB(255, 30, 64, 175), // Blue 800
    const Color.fromARGB(255, 29, 78, 216), // Blue 700
    const Color.fromARGB(255, 37, 99, 235), // Blue 600
    const Color.fromARGB(255, 59, 130, 246), // Blue 500
    const Color.fromARGB(255, 96, 165, 250), // Blue 400
    const Color.fromARGB(255, 147, 197, 253), // Blue 300
    const Color.fromARGB(255, 191, 219, 254), // Blue 200
    const Color.fromARGB(255, 219, 234, 254), // Blue 100
    const Color.fromARGB(255, 239, 246, 255), // Blue 50

    // Indigo
    const Color.fromARGB(255, 30, 27, 75), // Indigo 950
    const Color.fromARGB(255, 49, 46, 129), // Indigo 900
    const Color.fromARGB(255, 55, 48, 163), // Indigo 800
    const Color.fromARGB(255, 67, 56, 202), // Indigo 700
    const Color.fromARGB(255, 79, 70, 229), // Indigo 600
    const Color.fromARGB(255, 99, 102, 241), // Indigo 500
    const Color.fromARGB(255, 129, 140, 248), // Indigo 400
    const Color.fromARGB(255, 165, 180, 252), // Indigo 300
    const Color.fromARGB(255, 199, 210, 254), // Indigo 200
    const Color.fromARGB(255, 224, 231, 255), // Indigo 100
    const Color.fromARGB(255, 238, 242, 255), // Indigo 50

    // Violet
    const Color.fromARGB(255, 46, 16, 101), // Violet 950
    const Color.fromARGB(255, 76, 29, 149), // Violet 900
    const Color.fromARGB(255, 91, 33, 182), // Violet 800
    const Color.fromARGB(255, 109, 40, 217), // Violet 700
    const Color.fromARGB(255, 124, 58, 237), // Violet 600
    const Color.fromARGB(255, 139, 92, 246), // Violet 500
    const Color.fromARGB(255, 167, 139, 250), // Violet 400
    const Color.fromARGB(255, 196, 181, 253), // Violet 300
    const Color.fromARGB(255, 221, 214, 254), // Violet 200
    const Color.fromARGB(255, 237, 233, 254), // Violet 100
    const Color.fromARGB(255, 245, 243, 255), // Violet 50

    // Purple
    const Color.fromARGB(255, 59, 7, 100), // Purple 950
    const Color.fromARGB(255, 88, 28, 135), // Purple 900
    const Color.fromARGB(255, 107, 33, 168), // Purple 800
    const Color.fromARGB(255, 126, 34, 206), // Purple 700
    const Color.fromARGB(255, 147, 51, 234), // Purple 600
    const Color.fromARGB(255, 168, 85, 247), // Purple 500
    const Color.fromARGB(255, 192, 132, 252), // Purple 400
    const Color.fromARGB(255, 216, 180, 254), // Purple 300
    const Color.fromARGB(255, 233, 213, 255), // Purple 200
    const Color.fromARGB(255, 243, 232, 255), // Purple 100
    const Color.fromARGB(255, 250, 245, 255), // Purple 50

    // Fuchsia
    const Color.fromARGB(255, 74, 4, 78), // Fuchsia 950
    const Color.fromARGB(255, 112, 26, 117), // Fuchsia 900
    const Color.fromARGB(255, 134, 25, 143), // Fuchsia 800
    const Color.fromARGB(255, 162, 28, 175), // Fuchsia 700
    const Color.fromARGB(255, 192, 38, 211), // Fuchsia 600
    const Color.fromARGB(255, 217, 70, 239), // Fuchsia 500
    const Color.fromARGB(255, 232, 121, 249), // Fuchsia 400
    const Color.fromARGB(255, 240, 171, 252), // Fuchsia 300
    const Color.fromARGB(255, 245, 208, 254), // Fuchsia 200
    const Color.fromARGB(255, 250, 232, 255), // Fuchsia 100
    const Color.fromARGB(255, 253, 244, 255), // Fuchsia 50

    // Pink
    const Color.fromARGB(255, 80, 7, 36), // Pink 950
    const Color.fromARGB(255, 131, 24, 67), // Pink 900
    const Color.fromARGB(255, 157, 23, 77), // Pink 800
    const Color.fromARGB(255, 190, 24, 93), // Pink 700
    const Color.fromARGB(255, 219, 39, 119), // Pink 600
    const Color.fromARGB(255, 236, 72, 153), // Pink 500
    const Color.fromARGB(255, 244, 114, 182), // Pink 400
    const Color.fromARGB(255, 249, 168, 212), // Pink 300
    const Color.fromARGB(255, 251, 207, 232), // Pink 200
    const Color.fromARGB(255, 252, 231, 243), // Pink 100
    const Color.fromARGB(255, 253, 242, 248), // Pink 50

    // Rose
    const Color.fromARGB(255, 76, 5, 25), // Rose 950
    const Color.fromARGB(255, 136, 19, 55), // Rose 900
    const Color.fromARGB(255, 159, 18, 57), // Rose 800
    const Color.fromARGB(255, 190, 18, 60), // Rose 700
    const Color.fromARGB(255, 225, 29, 72), // Rose 600
    const Color.fromARGB(255, 244, 63, 94), // Rose 500
    const Color.fromARGB(255, 251, 113, 133), // Rose 400
    const Color.fromARGB(255, 253, 164, 175), // Rose 300
    const Color.fromARGB(255, 254, 205, 211), // Rose 200
    const Color.fromARGB(255, 255, 228, 230), // Rose 100
    const Color.fromARGB(255, 255, 241, 242), // Rose 50

    // Stone
    const Color.fromARGB(255, 12, 10, 9), // Stone 950
    const Color.fromARGB(255, 28, 25, 23), // Stone 900
    const Color.fromARGB(255, 41, 37, 36), // Stone 800
    const Color.fromARGB(255, 68, 64, 60), // Stone 700
    const Color.fromARGB(255, 87, 83, 78), // Stone 600
    const Color.fromARGB(255, 120, 113, 108), // Stone 500
    const Color.fromARGB(255, 168, 162, 158), // Stone 400
    const Color.fromARGB(255, 214, 211, 209), // Stone 300
    const Color.fromARGB(255, 231, 229, 228), // Stone 200
    const Color.fromARGB(255, 245, 245, 244), // Stone 100
    const Color.fromARGB(255, 250, 250, 249), // Stone 50

    // Neutral
    /*Color.fromARGB(255, 10, 10, 10), // Neutral 950
    Color.fromARGB(255, 23, 23, 23), // Neutral 900
    Color.fromARGB(255, 38, 38, 38), // Neutral 800
    Color.fromARGB(255, 64, 64, 64), // Neutral 700
    Color.fromARGB(255, 82, 82, 82), // Neutral 600
    Color.fromARGB(255, 115, 115, 115), // Neutral 500
    Color.fromARGB(255, 163, 163, 163), // Neutral 400
    Color.fromARGB(255, 212, 212, 212), // Neutral 300
    Color.fromARGB(255, 229, 229, 229), // Neutral 200
    Color.fromARGB(255, 245, 245, 245), // Neutral 100
    Color.fromARGB(255, 250, 250, 250), // Neutral 50

    // Zinc
    Color.fromARGB(255, 9, 9, 11), // Zinc 950
    Color.fromARGB(255, 24, 24, 27), // Zinc 900
    Color.fromARGB(255, 39, 39, 42), // Zinc 800
    Color.fromARGB(255, 63, 63, 70), // Zinc 700
    Color.fromARGB(255, 82, 82, 91), // Zinc 600
    Color.fromARGB(255, 113, 113, 122), // Zinc 500
    Color.fromARGB(255, 161, 161, 170), // Zinc 400
    Color.fromARGB(255, 212, 212, 216), // Zinc 300
    Color.fromARGB(255, 228, 228, 231), // Zinc 200
    Color.fromARGB(255, 244, 244, 245), // Zinc 100
    Color.fromARGB(255, 250, 250, 250), // Zinc 50

    // Gray
    Color.fromARGB(255, 3, 7, 18), // Gray 950
    Color.fromARGB(255, 17, 24, 39), // Gray 900
    Color.fromARGB(255, 31, 41, 55), // Gray 800
    Color.fromARGB(255, 55, 65, 81), // Gray 700
    Color.fromARGB(255, 75, 85, 99), // Gray 600
    Color.fromARGB(255, 107, 114, 128), // Gray 500
    Color.fromARGB(255, 156, 163, 175), // Gray 400
    Color.fromARGB(255, 209, 213, 219), // Gray 300
    Color.fromARGB(255, 229, 231, 235), // Gray 200
    Color.fromARGB(255, 243, 244, 246), // Gray 100
    Color.fromARGB(255, 249, 250, 251), // Gray 50

    // Slate
    Color.fromARGB(255, 2, 6, 23), // Slate 950
    Color.fromARGB(255, 15, 23, 42), // Slate 900
    Color.fromARGB(255, 30, 41, 59), // Slate 800
    Color.fromARGB(255, 51, 65, 85), // Slate 700
    Color.fromARGB(255, 71, 85, 105), // Slate 600
    Color.fromARGB(255, 100, 116, 139), // Slate 500
    Color.fromARGB(255, 148, 163, 184), // Slate 400
    Color.fromARGB(255, 203, 213, 225), // Slate 300
    Color.fromARGB(255, 226, 232, 240), // Slate 200
    Color.fromARGB(255, 241, 245, 249), // Slate 100
    Color.fromARGB(255, 248, 250, 252), // Slate 50 */
  ];

  openColorSheet(BuildContext context, CanvasTheme canvasTheme, String type) {
    showModalBottomSheet(
      backgroundColor: ThemeColor.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(36),
      ),
      context: context,
      builder: (context) {
        return Consumer(builder: (context, ref, child) {
          final stateNotifier = ref.read(canvasThemeProvider.notifier);
          return Container(
            padding: EdgeInsets.only(
              top: 12,
              bottom: MediaQuery.of(context).viewPadding.bottom,
              left: 12,
              right: 12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Center(
                  child: (() {
                    switch (type) {
                      case ("bgColor"):
                        return const Text("背景色");
                      case ("profileTextColor"):
                        return const Text("テキスト");
                      case ("profileSecondaryTextColor"):
                        return const Text("サブテキスト");
                      case ("profileLinksColor"):
                        return const Text("アイコン");
                      case ("profileAboutMeColor"):
                        return const Text("ひとこと");
                      case ("boxBgColor"):
                        return const Text("背景色");
                      case ("boxTextColor"):
                        return const Text("テキスト");
                      case ("boxSecondaryTextColor"):
                        return const Text("サブテキスト");
                      case ("iconGradientStartColor"):
                        return const Text("スタート");
                      case ("iconGradientEndColor"):
                        return const Text("エンド");
                    }
                    return const SizedBox();
                  })(),
                ),
                const Gap(16),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: GridView(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 11,
                        //childAspectRatio: 3,
                      ),
                      children: colorPalette
                          .map(
                            (item) => GestureDetector(
                              onTap: () {
                                switch (type) {
                                  case ("bgColor"):
                                    stateNotifier.state =
                                        canvasTheme.copyWith(bgColor: item);
                                  case ("profileTextColor"):
                                    stateNotifier.state = canvasTheme.copyWith(
                                        profileTextColor: item);
                                  case ("profileSecondaryTextColor"):
                                    stateNotifier.state = canvasTheme.copyWith(
                                        profileSecondaryTextColor: item);
                                  case ("profileLinksColor"):
                                    stateNotifier.state = canvasTheme.copyWith(
                                        profileLinksColor: item);
                                  case ("profileAboutMeColor"):
                                    stateNotifier.state = canvasTheme.copyWith(
                                        profileAboutMeColor: item);
                                  case ("boxBgColor"):
                                    stateNotifier.state =
                                        canvasTheme.copyWith(boxBgColor: item);
                                  case ("boxTextColor"):
                                    stateNotifier.state = canvasTheme.copyWith(
                                        boxTextColor: item);
                                  case ("boxSecondaryTextColor"):
                                    stateNotifier.state = canvasTheme.copyWith(
                                        boxSecondaryTextColor: item);
                                  case ("iconGradientStartColor"):
                                    stateNotifier.state = canvasTheme.copyWith(
                                        iconGradientStartColor: item);
                                  case ("iconGradientEndColor"):
                                    stateNotifier.state = canvasTheme.copyWith(
                                        iconGradientEndColor: item);
                                }
                                Navigator.pop(context);
                              },
                              child: Container(
                                color: item,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }
}
