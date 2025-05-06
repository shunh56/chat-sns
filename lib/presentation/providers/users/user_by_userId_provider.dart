import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/providers/users/all_users_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userByUserIdProvider = FutureProvider.family<UserAccount, String>(
  (ref, userId) async {
    final notifier = ref.watch(allUsersNotifierProvider.notifier);
    final user = await notifier.getUser(userId);
    if (user == null) {
      throw Exception('ユーザーが見つかりません');
    }
    return user;
  },
);
