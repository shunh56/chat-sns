import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UseInviteCodeScreen extends ConsumerStatefulWidget {
  const UseInviteCodeScreen({super.key});

  @override
  ConsumerState<UseInviteCodeScreen> createState() => _UseInviteCodeScreenState();
}

class _UseInviteCodeScreenState extends ConsumerState<UseInviteCodeScreen> {
  final _codeController = TextEditingController();
  final bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          '招待コードを入力',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            '招待コードをお持ちの方は\nこちらから入力してください',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),

          // コード入力フィールド
          TextField(
            controller: _codeController,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              letterSpacing: 8,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: 'コードを入力',
              hintStyle: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                letterSpacing: 0,
              ),
              filled: true,
              fillColor: Colors.grey[900],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 20,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 使用ボタン
          ElevatedButton(
            onPressed: _isLoading
                ? null
                : () {
                    // 招待コード処理の実装
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'コードを使用',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),

          // 特典の説明
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withOpacity(0.1),
                  Colors.purple.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blue.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '招待特典',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                _buildBenefitItem(
                  icon: Icons.star,
                  text: 'プレミアムテーマの解放',
                ),
                _buildBenefitItem(
                  icon: Icons.group,
                  text: 'グループチャット機能',
                ),
                _buildBenefitItem(
                  icon: Icons.workspace_premium,
                  text: '特別なプロフィールバッジ',
                ),
              ],
            ),
          ),

          // ヘルプテキスト
          const SizedBox(height: 24),
          Text(
            '招待コードは8文字の英数字で構成されています。\n大文字小文字は区別されません。',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
