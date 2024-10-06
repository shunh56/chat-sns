/*import 'dart:math';

import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/pages/temp/call_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';

class VoiceRoomFeed extends ConsumerWidget {
  const VoiceRoomFeed({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double cardHeight = 112;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 12),
          child: Text(
            "ボイスチャット",
            style: TextStyle(
              fontSize: 20,
              color: ThemeColor.headline,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Gap(6),
        SizedBox(
          height: cardHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemBuilder: (context, index) {
              int usersLength = 3 + Random().nextInt(3);
              return GestureDetector(
                onTap: () {
                  final roomId = const Uuid().v4();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const CallScreen() //VoiceRoomScreen(roomId: roomId),
                        ),
                  );
                },
                child: Container(
                  height: cardHeight,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: ThemeColor.beige,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: ThemeColor.button,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.call,
                              color: ThemeColor.beige,
                              size: 16,
                            ),
                            const Gap(2),
                            Text(
                              "$usersLength人通話中",
                              style: const TextStyle(
                                color: ThemeColor.beige,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                      const Text(
                        "THIS IS TITLE",
                        style: TextStyle(
                          color: ThemeColor.headline,
                          fontSize: 18,
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                      SizedBox(
                        height: 36,
                        width: 160,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 4,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.black.withOpacity(0.3),
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }
}
 */