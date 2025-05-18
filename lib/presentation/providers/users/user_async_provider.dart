import 'package:app/domain/entity/user.dart';
import 'package:app/presentation/providers/users/all_users_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userFutureProvider = FutureProvider.family<UserAccount, String>(
  (ref, userId) async {
    final notifier = ref.read(allUsersNotifierProvider.notifier);
    return notifier.getUserByUserId(userId);
  },
);
