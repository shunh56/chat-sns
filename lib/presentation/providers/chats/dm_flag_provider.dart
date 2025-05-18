import 'package:app/data/datasource/firebase/firebase_auth.dart';
import 'package:app/domain/entity/message_overview.dart';
import 'package:app/presentation/providers/chats/dm_overview_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<bool> dmFlagProvider = Provider<bool>(
  (ref) {
    bool flag = false;
    final overviews =
        ref.watch(dmOverviewListNotifierProvider).asData?.value ?? [];

    for (var overview in overviews) {
      final myInfoQ = overview.userInfoList.where(
        (item) => item.userId == ref.read(authProvider).currentUser!.uid,
      );
      if (myInfoQ.isEmpty) {
        flag = true;
        break;
      }
      final myInfo = myInfoQ.first;
      if (myInfo.lastOpenedAt.compareTo(overview.updatedAt) < 0) {
        flag = true;
        break;
      }
    }
    return flag;
  },
);

final dmFlagHelperProvider = Provider(
  (ref) => DMFlagHelper(ref.watch(authProvider)),
);

class DMFlagHelper {
  final FirebaseAuth _auth;
  DMFlagHelper(this._auth);
  bool checkFlag(DMOverview overview) {
    bool unseenCheck = false;
    final q = overview.userInfoList
        .where((item) => item.userId == _auth.currentUser!.uid);
    if (q.isEmpty) return true;
    final myInfo = q.first;
    if (myInfo.lastOpenedAt.compareTo(overview.updatedAt) < 0) {
      unseenCheck = true;
    }
    return unseenCheck;
  }
}
