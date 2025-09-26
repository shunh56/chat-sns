import 'dart:math' as math;

import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/components/core/shader.dart';
import 'package:app/presentation/pages/search/widgets/cosmic_background.dart';
import 'package:app/presentation/pages/search/widgets/stellar_user_widget.dart';
import 'package:app/presentation/pages/search/widgets/floating_controls.dart';
import 'package:app/presentation/providers/users/online_users.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class StellarDiscoveryScreen extends HookConsumerWidget {
  const StellarDiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    // 3D コントローラー
    //final controller3D = useMemoized(() => Flutter3DController());

    // ズームレベルとローテーション
    final zoomLevel = useState(1.0);
    final rotationX = useState(0.0);
    final rotationY = useState(0.0);

    // タッチ位置追跡
    final lastPanPosition = useState(Offset.zero);

    // ユーザーデータ
    final newUsers = ref.watch(newUsersNotifierProvider);
    final activeUsers = ref.watch(recentUsersNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 宇宙空間の背景
          const CosmicBackground(),

          // 3D空間のユーザー表示
          GestureDetector(
            onScaleUpdate: (details) {
              zoomLevel.value =
                  (zoomLevel.value * details.scale).clamp(0.5, 3.0);
            },
            onPanStart: (details) {
              lastPanPosition.value = details.localPosition;
            },
            onPanUpdate: (details) {
              final delta = details.localPosition - lastPanPosition.value;
              rotationY.value += delta.dx * 0.01;
              rotationX.value -= delta.dy * 0.01;
              lastPanPosition.value = details.localPosition;
            },
            child: Container(
              color: Colors.transparent,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(rotationX.value)
                  ..rotateY(rotationY.value)
                  ..scale(zoomLevel.value),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 新規ユーザーの表示
                    ...newUsers.when(
                      data: (users) => _buildUserPlanets(
                        users.where((u) => !u.isMe).take(10).toList(),
                        isNewUser: true,
                      ),
                      loading: () => [],
                      error: (_, __) => [],
                    ),

                    // アクティブユーザーの表示
                    ...activeUsers.when(
                      data: (users) => _buildUserPlanets(
                        users.where((u) => !u.isMe).take(10).toList(),
                        isNewUser: false,
                      ),
                      loading: () => [],
                      error: (_, __) => [],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // UI オーバーレイ
          SafeArea(
            child: Column(
              children: [
                // ヘッダー
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      ShaderWidget(
                        child: Text(
                          'Stellar Discovery',
                          style: textStyle.w700(
                            fontSize: 28,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon:
                            const Icon(Icons.filter_list, color: Colors.white),
                        onPressed: () {
                          // フィルター機能
                        },
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // フローティングコントロール
                FloatingControls(
                  onZoomIn: () {
                    zoomLevel.value = (zoomLevel.value * 1.2).clamp(0.5, 3.0);
                  },
                  onZoomOut: () {
                    zoomLevel.value = (zoomLevel.value / 1.2).clamp(0.5, 3.0);
                  },
                  onReset: () {
                    zoomLevel.value = 1.0;
                    rotationX.value = 0.0;
                    rotationY.value = 0.0;
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildUserPlanets(List<UserAccount> users,
      {required bool isNewUser}) {
    //final random = math.Random();
    return users.asMap().entries.map((entry) {
      final index = entry.key;
      final user = entry.value;

      // 3D空間での位置計算
      final angle = (index / users.length) * 2 * math.pi;
      final radius = isNewUser ? 150.0 : 250.0;
      //final height = random.nextDouble() * 100 - 50;

      return StellarUserWidget(
        user: user,
        orbitRadius: radius,
        angle: angle,
        isActive: user.isOnline,
        onTap: () {
          // ユーザープロフィールを開く
        },
      );
    }).toList();
  }
}
