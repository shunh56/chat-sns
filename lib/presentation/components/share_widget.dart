import 'dart:io';

import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/components/icons.dart';
import 'package:app/presentation/components/user_icon.dart';
import 'package:app/presentation/providers/provider/users/my_user_account_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:social_share/social_share.dart';
import 'package:url_launcher/url_launcher.dart';

const webUrl = "https://somekindoflink.com";
const appStoreUrl = "";
const message =
    "このプライベートなSNSコミュニティに参加しませんか？友達と安全に、楽しくつながれる場所です。リンクをクリックして始めてください！\n";

/*Future<Uint8List?> convertWidgetToImage() async {
  try {
    //final key = ref.watch(qrWidgetKey);
    // RenderObjectを取得
    RenderRepaintBoundary? boundary =
        key.currentContext?.findRenderObject() as RenderRepaintBoundary?;

    if (boundary == null) {
      print('Error: Unable to find RenderRepaintBoundary');
      return null;
    }

    // RenderObject を dart:ui の Image に変換する
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      print('Error: Unable to convert image to byte data');
      return null;
    }

    return byteData.buffer.asUint8List();
  } catch (e) {
    print('Error converting widget to image: $e');
    return null;
  }
} */

Future<void> shareByLine(String text) async {
  final lineUrl = Uri(
    scheme: 'https',
    host: 'line.me',
    path: 'R/msg/text/$message$webUrl',
  );
  await launchUrl(lineUrl, mode: LaunchMode.externalApplication);
}

Future<void> shareByTwitter(String text) async {
  final tweetQuery = <String, dynamic>{
    'text': message + webUrl,
    // 'url': 'https://...',
    // 'hashtags': ['tag1', 'tag2'],
  };

  final twitterUrl = Uri(
    scheme: 'https',
    host: 'twitter.com',
    path: 'intent/tweet',
    queryParameters: tweetQuery,
  );

  await launchUrl(twitterUrl, mode: LaunchMode.externalApplication);
}

//final key = GlobalKey();

//TODO SHARE WIDGET!!
class ShareWidget extends ConsumerWidget {
  const ShareWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final asyncValue = ref.watch(myAccountNotifierProvider);
    return asyncValue.maybeWhen(
        data: (me) {
          return RepaintBoundary(
            key: key,
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: themeSize.horizontalPadding,
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 24,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.purpleAccent.withOpacity(0.3),
                    Colors.cyan.withOpacity(0.3),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  UserIcon(user: me),
                  const Gap(12),
                  Text(
                    "友達を招待して\nチャットを始めよう!",
                    textAlign: TextAlign.center,
                    style: textStyle.w600(
                      fontSize: 16,
                      color: ThemeColor.white,
                    ),
                  ),
                  const Gap(16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          shareByLine("");
                        },
                        child: SizedBox(
                          height: 44,
                          width: 44,
                          child: Image.asset(
                            Images.lineIcon,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          try {
                            const image = null; // await convertWidgetToImage();

                            if (image != null) {
                              //await ImageGallerySaver.saveImage(capturedImage);
                              final tempDir = await getTemporaryDirectory();
                              final assetPath = '${tempDir.path}/temp.png';
                              File file = await File(assetPath).create();
                              await file.writeAsBytes(image);

                              await SocialShare.shareInstagramStory(
                                appId: "909800630776361",
                                imagePath: file.path,
                                backgroundTopColor: "#0F0F0F",
                                backgroundBottomColor: "#4F4F4F",
                                attributionURL: message + webUrl,
                              );
                            }
                          } catch (e) {
                            showMessage("error : $e");
                          }
                        },
                        child: SizedBox(
                          height: 36,
                          width: 36,
                          child: Image.asset(
                            Images.instagramIcon,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          shareByTwitter("");
                        },
                        child: SizedBox(
                          height: 30,
                          width: 30,
                          child: Image.asset(
                            Images.xIcon,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Share.share(message + webUrl);
                        },
                        child: Icon(
                          shareIcon,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
        orElse: () => const SizedBox());
  }
}
