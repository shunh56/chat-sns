import 'package:app/presentation/pages/community_screen/model/community.dart';
import 'package:app/repository/community_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final communityUsecaseProvider = Provider(
  (ref) => CommunityUsecase(
    ref.watch(communityRepositoryProvider),
  ),
);

class CommunityUsecase {
  final CommunityRepository _repository;
  CommunityUsecase(this._repository);

  Future<Community?> getCommunityFromId(String communityId) async {
    return _repository.getCommunityFromId(communityId);
  }

  Future<List<String>> getRecentUsers(String communityId) async {
    return _repository.getRecentUsers(communityId);
  }
}
