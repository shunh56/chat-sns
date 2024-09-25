import 'package:app/core/extenstions/timestamp_extenstion.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/reply.dart';
import 'package:app/presentation/components/user_icon.dart';
import 'package:app/presentation/navigation/navigator.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class ReplyWidget extends ConsumerWidget {
  const ReplyWidget({super.key, required this.reply});
  final Reply reply;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user =
        ref.read(allUsersNotifierProvider).asData!.value[reply.userId]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref.read(navigationRouterProvider(context)).goToProfile(user);
                },
                child: UserIcon.postIcon(user),
              ),
              const Gap(8),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Gap(4),
                          Row(
                            children: [
                              Text(
                                user.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: ThemeColor.text,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Gap(4),
                              Text(
                                "・${reply.createdAt.xxAgo}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: ThemeColor.subText,
                                ),
                              ),
                            ],
                          ),
                          const Gap(4),
                          Text(
                            reply.text,
                            style: const TextStyle(
                              fontSize: 16,
                              color: ThemeColor.text,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
