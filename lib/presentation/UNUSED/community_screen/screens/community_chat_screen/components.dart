// lib/presentation/pages/community/components/community_options_sheet.dart

import 'package:app/core/utils/debug_print.dart';
import 'package:app/presentation/UNUSED/community_screen/model/community.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:app/domain/usecases/comunity_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommunityOptionsSheet extends ConsumerWidget {
  final Community community;

  const CommunityOptionsSheet({
    super.key,
    required this.community,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOptionTile(
            icon: Icons.people,
            title: 'メンバー一覧',
            onTap: () {
              // TODO: Navigate to members list
              Navigator.pop(context);
            },
          ),
          _buildOptionTile(
            icon: Icons.info,
            title: 'コミュニティ情報',
            onTap: () {
              // TODO: Navigate to community info
              Navigator.pop(context);
            },
          ),
          if (_isModeratorOrAdmin(ref)) ...[
            _buildOptionTile(
              icon: Icons.settings,
              title: 'コミュニティ設定',
              onTap: () {
                // TODO: Navigate to community settings
                Navigator.pop(context);
              },
            ),
          ],
          _buildOptionTile(
            icon: Icons.exit_to_app,
            title: '退会する',
            onTap: () async {
              Navigator.pop(context);
              await _confirmLeave(context);
            },
            textColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: textColor ?? Colors.white,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.white,
        ),
      ),
      onTap: onTap,
    );
  }

  bool _isModeratorOrAdmin(WidgetRef ref) {
    final uid = ref.read(authProvider).currentUser!.uid;
    return community.moderators.contains(uid);
  }

  Future<void> _confirmLeave(BuildContext context) async {
    await showDialog<bool>(
      context: context,
      builder: (context) => Consumer(builder: (context, ref, widget) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text(
            'コミュニティから退会',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            '本当にこのコミュニティから退会しますか？',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await ref
                      .read(communityUsecaseProvider)
                      .leaveCommunity(community);
                  if (context.mounted) {
                    DebugPrint("CONTEXT MOUNTED");
                    Navigator.pop(context);
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('退会に失敗しました: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text(
                '退会する',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      }),
    );
  }
}
