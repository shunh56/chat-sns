import 'package:app/presentation/providers/invite_code_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
//import 'package:share_plus/share_plus.dart';

// 招待方法を選択するシート

class MileStoneScreen extends ConsumerWidget {
  const MileStoneScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inviteCode = ref.watch(myInviteCodeNotifierProvider);
    final invitedUsersCount = inviteCode.logs.length;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          '機能の解放',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        children: [
          // 進捗状況
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '招待の進捗',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.people, color: Colors.blue, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          '$invitedUsersCount人招待済み',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // 進捗バー
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.grey[800],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width *
                            (invitedUsersCount / 10), // 10人を最大とする
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          gradient: const LinearGradient(
                            colors: [Colors.blue, Colors.purple],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // キャンペーンバナー
          if (invitedUsersCount < 3) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withOpacity(0.2),
                      Colors.purple.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '期間限定キャンペーン',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '今週末まで！招待3人でプレミアムテーマをプレゼント',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // 機能リスト
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '解放できる機能',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                // 機能カード
                _buildFeatureCard(
                  title: '複数画像投稿',
                  description: '1回の投稿で最大4枚まで',
                  icon: Icons.image,
                  isUnlocked:
                      invitedUsersCount >= 1 || inviteCode.usedCode != null,
                ),
                _buildFeatureCard(
                  title: 'グループチャット',
                  description: '複数人でチャットを作成',
                  icon: Icons.group,
                  isUnlocked: invitedUsersCount >= 3,
                  requiredInvites: 3,
                  currentInvites: invitedUsersCount,
                ),
                _buildFeatureCard(
                  title: 'ビデオ通話',
                  description: '友達とビデオ通話',
                  icon: Icons.videocam,
                  isUnlocked: invitedUsersCount >= 5,
                  requiredInvites: 5,
                  currentInvites: invitedUsersCount,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () => _handleInvite(context, inviteCode.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '友達を招待する',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String description,
    required IconData icon,
    required bool isUnlocked,
    int? requiredInvites,
    int? currentInvites,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnlocked ? Colors.blue.withOpacity(0.3) : Colors.grey[800]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color:
                  isUnlocked ? Colors.blue.withOpacity(0.1) : Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isUnlocked ? Colors.blue : Colors.grey,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isUnlocked ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (!isUnlocked && requiredInvites != null)
            Text(
              'あと${requiredInvites - (currentInvites ?? 0)}人',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          if (isUnlocked)
            const Icon(
              Icons.check_circle,
              color: Colors.blue,
            ),
        ],
      ),
    );
  }

  void _handleInvite(BuildContext context, String inviteCode) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => InviteMethodSheet(inviteCode: inviteCode),
    );

    if (result == null) return;
  }
}

// invite_bottom_sheet.dart
class InviteMethodSheet extends ConsumerWidget {
  final String inviteCode;
  const InviteMethodSheet({required this.inviteCode, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ドラッグハンドル
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // ヘッダー
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Text(
                  '友達を招待',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '招待した友達と一緒に機能を解放しよう！',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 招待方法リスト
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildInviteOption(
                  context: context,
                  icon: Icons.qr_code_scanner,
                  title: 'QRコードを表示',
                  subtitle: '近くにいる友達とすぐに共有',
                  gradient: const [Colors.blue, Colors.purple],
                  onTap: () => _showQRCode(context),
                ),
                const SizedBox(height: 12),
                _buildInviteOption(
                  context: context,
                  icon: Icons.share,
                  title: '招待リンクをシェア',
                  subtitle: 'SNSやメッセージで友達に送る',
                  gradient: const [Colors.purple, Colors.pink],
                  onTap: () => _shareInviteLink(context),
                ),
                const SizedBox(height: 12),
                _buildInviteOption(
                  context: context,
                  icon: Icons.copy,
                  title: '招待コードをコピー',
                  subtitle: '8文字のコードを共有',
                  gradient: const [Colors.pink, Colors.orange],
                  onTap: () => _copyInviteCode(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 招待コード表示
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[800]!),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'あなたの招待コード',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _copyInviteCode(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.copy,
                              color: Colors.blue,
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'コピー',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  inviteCode,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInviteOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                gradient[0].withOpacity(0.1),
                gradient[1].withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: gradient[0].withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      gradient[0].withOpacity(0.2),
                      gradient[1].withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: gradient[0],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[600],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQRCode(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRCodeScreen(inviteCode: inviteCode),
      ),
    );
  }

  void _shareInviteLink(BuildContext context) async {
    /*final dynamicLink = "https://yourdomain.com/invite?code=$inviteCode";
    await Share.share(
      '一緒にアプリを楽しもう！\n$dynamicLink',
      subject: 'アプリへの招待',
    ); */
    if (context.mounted) Navigator.pop(context);
  }

  void _copyInviteCode(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: inviteCode));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('招待コードをコピーしました'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }
}

class QRCodeScreen extends StatelessWidget {
  final String inviteCode;

  const QRCodeScreen({super.key, required this.inviteCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('QRコード'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // QRコード
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(32),
                child: PrettyQrView.data(
                  decoration: const PrettyQrDecoration(
                    shape: PrettyQrSmoothSymbol(
                      roundFactor: 0.8,
                      color: Colors.black,
                    ),
                  ),
                  data: inviteCode,
                  errorCorrectLevel: QrErrorCorrectLevel.L,
                ),
              ),
              const SizedBox(height: 20),

              // 招待コード
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: inviteCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('招待コードをコピーしました')),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      inviteCode,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.copy, color: Colors.white, size: 20),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // 説明文
              const Text(
                'このQRコードを友達にスキャンしてもらうと\nアプリに参加できます',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 40),

              // シェアボタン
              ElevatedButton.icon(
                onPressed: () {
                  // シェア機能
                  // Share.share('アプリに参加するにはこちらのコードを使用してください: $inviteCode');
                },
                icon: const Icon(Icons.share),
                label: const Text('シェアする'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
