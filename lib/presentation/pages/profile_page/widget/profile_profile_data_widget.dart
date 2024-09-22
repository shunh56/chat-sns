import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/pages/profile_page/sub_screens/edit_tags/edit_basic_tags.dart';
import 'package:app/presentation/pages/profile_page/sub_screens/edit_tags/edit_lifestyle_tags.dart';
import 'package:app/presentation/pages/profile_page/sub_screens/edit_tags/edit_social_media_tags.dart';
import 'package:app/presentation/pages/profile_page/sub_screens/edit_tags/edit_music_tags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

List<String> tags = [
  "24歳",
  "学生",
  "早稲田大学",
  "東京",
  "178cm",
  "A型",
  "INTP",
  "犬",
];

List<String> socialTags = [
  "Instagram",
  "Twitter",
  "LINE",
  "TikTok",
];

List<String> musicTags = [
  "K-Pop",
  "邦楽",
  "洋楽",
  "EDM",
  "Techno",
];

List<String> lifestyleTags = [
  "遅寝",
  "遅起き",
  "夜型",
  "のんびり",
  "雑談",
];

class ProfileDataFeed extends ConsumerWidget {
  const ProfileDataFeed({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  "基本プロフィール",
                  style: TextStyle(
                    fontSize: 14,
                    color: ThemeColor.highlight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Expanded(child: SizedBox()),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditBasicTagsScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: ThemeColor.beige,
                    ),
                    child: const Text(
                      "編集",
                      style: TextStyle(
                        fontSize: 12,
                        color: ThemeColor.highlight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Gap(8),
            Wrap(
              children: tags
                  .map(
                    (tag) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: ThemeColor.highlight,
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
        const Gap(24),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  "ソーシャルメディア",
                  style: TextStyle(
                    fontSize: 14,
                    color: ThemeColor.highlight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Expanded(child: SizedBox()),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditSocialMediaTagsScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: ThemeColor.beige,
                    ),
                    child: const Text(
                      "編集",
                      style: TextStyle(
                        fontSize: 12,
                        color: ThemeColor.highlight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Gap(8),
            Wrap(
              children: socialTags
                  .map(
                    (tag) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: ThemeColor.highlight,
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
        const Gap(24),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  "音楽",
                  style: TextStyle(
                    fontSize: 14,
                    color: ThemeColor.highlight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Expanded(child: SizedBox()),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditMusicTagsScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: ThemeColor.beige,
                    ),
                    child: const Text(
                      "編集",
                      style: TextStyle(
                        fontSize: 12,
                        color: ThemeColor.highlight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Gap(8),
            Wrap(
              children: musicTags
                  .map(
                    (tag) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: ThemeColor.highlight,
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
        const Gap(24),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  "ライフスタイル",
                  style: TextStyle(
                    fontSize: 14,
                    color: ThemeColor.highlight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Expanded(child: SizedBox()),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditLifestyleTagsScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: ThemeColor.beige,
                    ),
                    child: const Text(
                      "編集",
                      style: TextStyle(
                        fontSize: 12,
                        color: ThemeColor.highlight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Gap(8),
            Wrap(
              children: lifestyleTags
                  .map(
                    (tag) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: ThemeColor.highlight,
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ],
    );
  }
}
