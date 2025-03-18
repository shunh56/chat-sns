import 'package:flutter_riverpod/flutter_riverpod.dart';

// ダークモード状態を管理するプロバイダー
final isDarkModeProvider = StateProvider<bool>((ref) => true);
