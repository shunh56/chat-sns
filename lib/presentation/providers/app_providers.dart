import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/utils/theme.dart';

/// テーマサイズプロバイダー
final themeSizeProvider = Provider.family<ThemeSize, BuildContext>((ref, context) {
  return ThemeSize(size: MediaQuery.of(context).size);
});