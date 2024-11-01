import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/pages/onboarding_page/input_invite_code_screen.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class AwaitingScreen extends ConsumerWidget {
  const AwaitingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    final text = FutureBuilder(
      future: ref
          .read(firestoreProvider)
          .collection("users")
          .where("usedCode", isEqualTo: "WAITING")
          .orderBy("createdAt")
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Text(
            "あなたは〇〇番目です",
            style: textStyle.w600(
              fontSize: 20,
            ),
          );
        }
        final length = snapshot.data!.docs.length;
        return Text(
          "あなたは$length番目です",
          style: textStyle.w600(
            fontSize: 20,
          ),
        );
      },
    );
    return GestureDetector(
      onTap: () {
        primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            GestureDetector(
              onTap: () {
                
                showUpcomingSnackbar();
              },
              child: const Icon(
                Icons.notifications,
                color: ThemeColor.icon,
              ),
            ),
            Gap(
              themeSize.horizontalPadding,
            ),
          ],
        ),
        body: Center(
          child: Column(
            children: [
              Gap(themeSize.screenHeight * 0.2),
              text,
              const Gap(12),
              Text(
                "もうしばらくお持ちください。",
                style: textStyle.w600(
                  fontSize: 14,
                  color: ThemeColor.subText,
                ),
              ),
              const Expanded(child: SizedBox()),
              Container(
                margin: EdgeInsets.symmetric(
                    horizontal: themeSize.horizontalPadding),
                child: Material(
                  color: ThemeColor.stroke,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () {
                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const InputInviteCodeScreen(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          "招待コードを入力",
                          style: textStyle.w600(
                            fontSize: 18,
                            color: ThemeColor.subText,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Gap(12),
              Container(
                margin: EdgeInsets.symmetric(
                    horizontal: themeSize.horizontalPadding),
                child: Material(
                  color: ThemeColor.stroke,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () {
                      
                      showUpcomingSnackbar();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          "ファストパスを買う",
                          style: textStyle.w600(
                            fontSize: 18,
                            color: ThemeColor.subText,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Gap(MediaQuery.of(context).viewPadding.bottom),
            ],
          ),
        ),
      ),
    );
  }
}
