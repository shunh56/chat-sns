/*import 'package:app/domain/entity/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

class UserBottomSheet {
  UserBottomSheet(this.ref);
  final WidgetRef ref;

  openUserBottomSheet(BuildContext context, UserAccount user) {
    
    const imageHeight = 80.0;
    const imagePadding = 2.0;
    showModalBottomSheet(
      //高さ調整
      backgroundColor: MainThemeColors.bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(36),
      ),
      context: context,
      builder: (context) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
            ScreenMethods().goToProfile(context, user, ref);
          },
          child: Container(
            width: MediaQuery.sizeOf(context).width,
            padding: const EdgeInsets.only(
              bottom: 72,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(36),
                    topRight: Radius.circular(36),
                  ),
                  child: SizedBox(
                    height:
                        designSize.thumbnailH + imageHeight / 2 + imagePadding,
                    child: Stack(
                      children: [
                        //thumbnail image
                        Positioned(
                          top: 0,
                          child: ProfileThumbnailImage(
                            thumbnailImageUrl: user.thumbnailImageUrl,
                          ),
                        ),
                        //profile image
                        Positioned(
                          top: designSize.thumbnailH -
                              imageHeight / 2 -
                              imagePadding,
                          left: 10,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  imageHeight / 3 + imagePadding),
                              border: Border.all(
                                color: MainThemeColors.bg,
                                width: imagePadding,
                              ),
                            ),
                            child: UserProfileImage().displayImage(
                              user.imageUrl,
                              user.username,
                              imageHeight / 2,
                            ),
                          ),
                        ),
                        //buttons
                        Positioned(
                          top: designSize.thumbnailH + 8,
                          right: 12,
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  ScreenMethods()
                                      .goToChatScreen(context, user, ref);
                                },
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.grey[800],
                                  child: const Center(
                                    child: Icon(
                                      Icons.chat_bubble_outline_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const Gap(8),
                              FollowButton(user: user),
                              const Gap(8),
                              GestureDetector(
                                onTap: () {
                                  UserBottomSheet(ref)
                                      .openBottomSheet(context, user);
                                },
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.grey[800],
                                  child: const Center(
                                    child: Icon(
                                      Icons.more_horiz_outlined,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap(12),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username,
                        overflow: TextOverflow.clip,
                        style: CustomTextStyle.jpText(
                          20,
                          Colors.white,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "@${user.username}.yolo",
                              overflow: TextOverflow.clip,
                              style: const TextStyle(
                                color: MainThemeColors.username,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const Gap(8),
                            user.aboutMe != null
                                ? Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      user.aboutMe!,
                                      style: GoogleFonts.notoSans(
                                        color: MainThemeColors.text,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      ),
                      Container(
                        height: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  openBottomSheet(BuildContext context, UserAccount user) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(36),
      ),
      context: context,
      builder: (context) {
        return Container(
          width: MediaQuery.sizeOf(context).width,
          padding: const EdgeInsets.only(
            top: 12,
            bottom: 72,
            left: 12,
            right: 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                height: 4,
                width: MediaQuery.sizeOf(context).width / 8,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              const Gap(24),
              /*   Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    width: 0.8,
                    color: Colors.grey,
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "共有",
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const Icon(
                        shareIcon,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(16),
              */
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    width: 0.8,
                    color: Colors.grey,
                  ),
                ),
                child: Column(
                  children: [
                    /* Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "アカウントをミュート",
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.8),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const Icon(
                            Icons.volume_off_outlined,
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      color: Colors.grey,
                      height: 0.8,
                      thickness: 0.8,
                    ), */
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        Navigator.pop(context);
                        openBlockBottomSheet(context, user);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "アカウントをブロック",
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.8),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const Icon(
                              Icons.block_outlined,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(
                      color: Colors.grey,
                      height: 0.8,
                      thickness: 0.8,
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        Navigator.pop(context);
                        openReportBottomSheet(context, user);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "アカウントを報告",
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.8),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const Icon(
                              Icons.flag_outlined,
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
      },
    );
  }

  openBlockBottomSheet(BuildContext context, UserAccount user) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(36),
      ),
      context: context,
      builder: (context) {
        return Container(
          width: MediaQuery.sizeOf(context).width,
          padding: const EdgeInsets.only(
            top: 12,
            bottom: 72,
            left: 12,
            right: 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Container(
                  height: 4,
                  width: MediaQuery.sizeOf(context).width / 8,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              const Gap(24),
              const Text(
                "アカウントをブロックしますか？",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(8),
              Text(
                "一度ブロックすると、相手には通知されませんが、ブロック解除するまで再び接触することはできません。\nブロックは慎重に行い、必要であれば報告機能を利用して不適切な行動を管理者に通知してください。",
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 12,
                ),
              ),
              const Gap(24),
              Material(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () async {
                    await ref
                        .read(blocksListNotifierProvider.notifier)
                        .blockUser(user);
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: const Center(
                      child: Text(
                        "ブロック",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Gap(8),
              Material(
                color: Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: Text(
                        "キャンセル",
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  final reportIndexProvider = StateProvider((ref) => -1);
  final pageController = Provider((ref) => PageController());
  final textContoller = Provider((ref) => TextEditingController());
  List<String> reasons = [
    "Inappropriate Content",
    "Harrasment",
    "Spam",
    "Impersonation",
    "Others",
  ];
  openReportBottomSheet(BuildContext context, UserAccount user) {
    showModalBottomSheet(
      //高さ調整
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(36),
      ),
      context: context,
      builder: (context) {
        return Container(
          width: MediaQuery.sizeOf(context).width,
          padding: const EdgeInsets.only(
            top: 12,
            bottom: 72,
            left: 12,
            right: 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Center(
                child: Container(
                  height: 4,
                  width: MediaQuery.sizeOf(context).width / 8,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              const Gap(24),
              SizedBox(
                height: MediaQuery.sizeOf(context).height / 2,
                child: PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: ref.watch(pageController),
                  children: [
                    //select
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "ユーザーを報告",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Gap(8),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            ref.read(reportIndexProvider.notifier).state = 0;
                            ref.read(pageController).nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOutQuint);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.black.withOpacity(0.05),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "不適切なコンテンツ",
                                        style: TextStyle(
                                          color: Colors.black.withOpacity(0.7),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Gap(2),
                                      Text(
                                        "このユーザーは不適切な画像やメッセージを投稿しています。",
                                        style: TextStyle(
                                          color: Colors.black.withOpacity(0.7),
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Gap(8),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.black.withOpacity(0.5),
                                  size: 16,
                                )
                              ],
                            ),
                          ),
                        ),
                        const Gap(8),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            ref.read(reportIndexProvider.notifier).state = 1;
                            ref.read(pageController).nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOutQuint);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.black.withOpacity(0.05),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "嫌がらせまたは脅迫",
                                        style: TextStyle(
                                          color: Colors.black.withOpacity(0.7),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Gap(2),
                                      Text(
                                        "このユーザーは嫌がらせや脅迫的なメッセージを送信しています。",
                                        style: TextStyle(
                                          color: Colors.black.withOpacity(0.7),
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Gap(8),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.black.withOpacity(0.5),
                                  size: 16,
                                )
                              ],
                            ),
                          ),
                        ),
                        const Gap(8),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            ref.read(reportIndexProvider.notifier).state = 2;
                            ref.read(pageController).nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOutQuint);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.black.withOpacity(0.05),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "スパム行為",
                                        style: TextStyle(
                                          color: Colors.black.withOpacity(0.7),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Gap(2),
                                      Text(
                                        "このユーザーは無関係な広告やリンクを頻繁に送信しています。",
                                        style: TextStyle(
                                          color: Colors.black.withOpacity(0.7),
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Gap(8),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.black.withOpacity(0.5),
                                  size: 16,
                                )
                              ],
                            ),
                          ),
                        ),
                        const Gap(8),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            ref.read(reportIndexProvider.notifier).state = 3;
                            ref.read(pageController).nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOutQuint);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.black.withOpacity(0.05),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "偽装または成りすまし",
                                        style: TextStyle(
                                          color: Colors.black.withOpacity(0.7),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Gap(2),
                                      Text(
                                        "このユーザーは他人になりすまし、虚偽の情報を提供しています。",
                                        style: TextStyle(
                                          color: Colors.black.withOpacity(0.7),
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Gap(8),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.black.withOpacity(0.5),
                                  size: 16,
                                )
                              ],
                            ),
                          ),
                        ),
                        const Gap(8),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            ref.read(reportIndexProvider.notifier).state = 4;
                            ref.read(pageController).nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOutQuint);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.black.withOpacity(0.05),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "その他",
                                        style: TextStyle(
                                          color: Colors.black.withOpacity(0.7),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Gap(2),
                                      Text(
                                        "他の選択肢に当てはまらない問題",
                                        style: TextStyle(
                                          color: Colors.black.withOpacity(0.7),
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Gap(8),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.black.withOpacity(0.5),
                                  size: 16,
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            ref.read(pageController).animateToPage(
                                  0,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOutQuint,
                                );
                          },
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.black.withOpacity(0.05),
                            child: Center(
                              child: Icon(
                                Icons.arrow_back_ios_rounded,
                                color: Colors.black.withOpacity(0.5),
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                        const Gap(12),
                        Text(
                          "オプションとして以下に追加情報をご記入ください。",
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Gap(8),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.black.withOpacity(0.05),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          child: TextField(
                            controller: ref.watch(textContoller),
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 12,
                            ),
                            maxLines: null,
                            maxLength: 200,
                            keyboardType: TextInputType.multiline,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const Expanded(child: SizedBox()),
                        Material(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            onTap: () async {
                              /*
                              final reportPresenterProvider =
                                  ref.watch(reportPresenter);
                              reportPresenterProvider.sendReport(
                                  reportForm, user.userId, me.userId); */
                              /*  ref
                            .read(notificationPresenterProvider)
                            .sendNotification(
                                user, NotificationType.userWarning); */
                              final me = ref
                                  .read(myAccountNotifierProvider)
                                  .asData!
                                  .value;
                              SlackApiMethods.sendUserReport(
                                  "\n${DateTime.now().toString().substring(0, 19)}\n\n[From] :\nname : ${me.username}\nid : ${me.userId}\n\n[To] :\nname : ${user.username}\nid : ${user.userId}\n\nReason : ${reasons[ref.read(reportIndexProvider)]}\nMessage :\n${ref.read(textContoller).text}\n");
                              showMessage(
                                  "ユーザーへの報告が完了しました。コミュニティ改善へのご協力ありがとうございます。",
                                  2400);
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: const Center(
                                child: Text(
                                  "報告を送信",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Gap(8),
                        Material(
                          color: Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: Text(
                                  "キャンセル",
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.7),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
 */