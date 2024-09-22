// Flutter imports:
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/message.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CenterMessage extends ConsumerWidget {
  const CenterMessage({super.key, required this.message});
  final CoreMessage message;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(
            top: 4,
            bottom: 4,
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 6,
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            color: ThemeColor.text.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            message.text,
          ),
        ),
      ],
    );
  }
}
