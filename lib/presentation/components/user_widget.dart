import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/providers/users/user_async_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserWidget extends ConsumerWidget {
  const UserWidget({
    super.key,
    required this.userId,
    required this.builder,
  });

  final String userId;
  final Widget Function(UserAccount user) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(userFutureProvider(userId));

    return asyncValue.when(
      data: (user) {
        if (user.accountStatus != AccountStatus.normal) {
          return const Text("ABNORMAL USER");
        }
        return builder(user);
      },
      error: (e, s) => Text("error: $e"),
      loading: () => const SizedBox(),
    );
  }
}
