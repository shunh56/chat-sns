import 'package:app/presentation/pages/community_screen/model/community.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CommunityMembersScreen extends ConsumerWidget {
  const CommunityMembersScreen({super.key, required this.community});
  final Community community;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold();
  }
}
