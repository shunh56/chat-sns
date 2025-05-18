import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class PopupContent extends ConsumerWidget {
  final String id;
  final bool dismissible;
  final Duration displayDuration;

  const PopupContent({
    super.key,
    required this.id,
    this.dismissible = true,
    this.displayDuration = const Duration(days: 365),
  });

  // 表示条件を確認するメソッド（オーバーライド可能）
  Future<bool> shouldDisplay() async {
    return true;
  }
}
