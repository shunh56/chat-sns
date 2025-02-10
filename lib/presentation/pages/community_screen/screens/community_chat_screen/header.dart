// lib/presentation/pages/community/components/community_chat_header.dart

import 'package:app/presentation/pages/community_screen/model/community.dart';
import 'package:flutter/material.dart';
import 'package:app/presentation/components/image/image.dart';

class CommunityChatHeader extends StatelessWidget {
  final Community community;

  const CommunityChatHeader({
    super.key,
    required this.community,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.purple.shade600],
              ),
              shape: BoxShape.circle,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                width: 48,
                height: 48,
                child: CachedImage.postImage(
                  community.thumbnailImageUrl,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  community.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${community.memberCount}人のメンバー',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
