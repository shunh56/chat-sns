// Project imports:

import 'package:app/data/datasource/mute_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final muteRepositoryProvider = Provider(
  (ref) => MuteRepository(
    ref.watch(muteDatasourceProvider),
    // ref.watch(friendsDatasourceProvider),
  ),
);

class MuteRepository {
  final MuteDatasource _muteDatasource;
  //final FriendsDatasource _friendsDatasource;

  MuteRepository(
    this._muteDatasource,
    // this._friendsDatasource,
  );

  Future<List<String>> getMutes() async {
    final res = await _muteDatasource.getMutes();
    return res.docs.map((e) => e.id).toList();
  }

  Future<void> muteUser(String userId) async {
    return _muteDatasource.muteUser(userId);
  }

  Future<void> unMuteUser(String userId) async {
    return await _muteDatasource.unMuteUser(userId);
  }
}
