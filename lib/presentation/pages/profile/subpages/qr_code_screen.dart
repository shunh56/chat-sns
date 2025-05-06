import 'dart:math';

import 'package:app/core/utils/debug_print.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/icons.dart';
import 'package:app/presentation/providers/users/my_user_account_notifier.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class QrCodeScreen extends ConsumerWidget {
  const QrCodeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final me = ref.read(myAccountNotifierProvider).asData!.value;
    final qrJsonData = {
      "userId": me.userId,
      "username": me.username,
      "link": "https://appname.vercel.app/@${me.username}",
    };
    DebugPrint(qrJsonData.toString());
    return Scaffold(
      backgroundColor: me.canvasTheme.bgColor,
      appBar: AppBar(
        backgroundColor: me.canvasTheme.bgColor,
        iconTheme: IconThemeData(
          color: me.canvasTheme.profileTextColor,
        ),
        actions: [
          Icon(
            Icons.qr_code_rounded,
            color: me.canvasTheme.profileTextColor,
          ),
          Gap(themeSize.horizontalPadding),
        ],
      ),
      body: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: themeSize.horizontalPaddingLarge),
        child: Column(
          children: [
            Gap(themeSize.screenHeight * 0.1),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 48),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: me.canvasTheme.boxBgColor,
                      /* gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.cyan,
                          Colors.pinkAccent,
                        ],
                      ), */
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: themeSize.screenWidth * 0.6,
                          width: themeSize.screenWidth * 0.6,
                          child: PrettyQrView.data(
                            decoration: PrettyQrDecoration(
                              shape: PrettyQrSmoothSymbol(
                                roundFactor: 0.8,
                                color: me.canvasTheme.boxTextColor,
                                // color: _PrettyQrSettings.kDefaultQrDecorationBrush,
                              ),
                              image: me.imageUrl != null
                                  ? PrettyQrDecorationImage(
                                      image: CachedNetworkImageProvider(
                                        me.imageUrl!,
                                      ),
                                    )
                                  : null,
                            ),
                            data: qrJsonData.toString(),
                            errorCorrectLevel: QrErrorCorrectLevel.L,
                          ),
                        ),
                        const Gap(36),
                        Text(
                          me.username,
                          style: TextStyle(
                            color: me.canvasTheme.boxTextColor,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const Gap(12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: me.canvasTheme.boxBgColor,
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            shareIcon,
                            color: me.canvasTheme.boxTextColor,
                            size: 24,
                          ),
                          const Gap(2),
                          Text(
                            "プロフィールをシェア",
                            style: TextStyle(
                              color: me.canvasTheme.boxTextColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: me.canvasTheme.boxBgColor,
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Transform.rotate(
                            angle: -pi / 4,
                            child: Icon(
                              Icons.link_outlined,
                              color: me.canvasTheme.boxTextColor,
                              size: 24,
                            ),
                          ),
                          const Gap(2),
                          Text(
                            "リンクをコピー",
                            style: TextStyle(
                              color: me.canvasTheme.boxTextColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
