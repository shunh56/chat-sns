import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/data/datasource/firebase/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// メンテナンス情報を管理するためのモデル
class MaintenanceInfo {
  final String? endTime;
  final String? description;

  MaintenanceInfo({
    this.endTime,
    this.description,
  });

  factory MaintenanceInfo.fromMap(Map<String, dynamic> map) {
    return MaintenanceInfo(
      endTime: map['endTime'] as String?,
      description: map['description'] as String?,
    );
  }
}

// メンテナンス情報を取得するためのProvider
final maintenanceInfoProvider = FutureProvider<MaintenanceInfo>((ref) async {
  final remoteConfig = ref.watch(remoteConfigProvider).asData!.value;
  final endTime = remoteConfig.getString("maintenance_end_time");
  final description = remoteConfig.getString("maintenance_description");
  return MaintenanceInfo(
    endTime: endTime,
    description: description,
  );
});

class MaintenanceScreen extends HookConsumerWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);

    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 1200),
    );

    final fadeAnimation = useAnimation(
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: animationController,
          curve: Curves.easeOut,
        ),
      ),
    );

    final scaleAnimation = useAnimation(
      Tween<double>(begin: 0.95, end: 1.0).animate(
        CurvedAnimation(
          parent: animationController,
          curve: Curves.easeOut,
        ),
      ),
    );

    // メンテナンス情報のステート
    final maintenanceInfo = useState<MaintenanceInfo?>(null);

    // メンテナンス情報を取得する関数
    Future<void> fetchMaintenanceInfo() async {
      try {
        final info = await ref.read(maintenanceInfoProvider.future);
        maintenanceInfo.value = info;
      } catch (e) {
        // エラー処理
      }
    }

    useEffect(() {
      animationController.forward();
      fetchMaintenanceInfo();
      return null;
    }, []);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Opacity(
            opacity: fadeAnimation,
            child: Transform.scale(
              scale: scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.engineering_rounded,
                      size: 48,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text('メンテナンス中', style: textStyle.w600(fontSize: 20)),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        Text(
                          'ただいまサービスのメンテナンスを行っています\nご不便をおかけし申し訳ございません',
                          textAlign: TextAlign.center,
                          style: textStyle.w600(
                            color: ThemeColor.subText,
                          ),
                        ),
                        if (maintenanceInfo.value != null) ...[
                          const SizedBox(height: 48),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '予定終了時刻',
                                  style: textStyle.w600(
                                    fontSize: 12,
                                    color: ThemeColor.subText,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  maintenanceInfo.value?.endTime ?? '未定',
                                  style: textStyle.w600(
                                    fontSize: 16,
                                  ),
                                ),
                                if (maintenanceInfo.value?.description !=
                                    null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    maintenanceInfo.value!.description!,
                                    textAlign: TextAlign.center,
                                    style: textStyle.w400(
                                      fontSize: 12,
                                      color: ThemeColor.subText,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
