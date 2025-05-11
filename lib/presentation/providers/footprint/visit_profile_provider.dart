import 'package:app/domain/entity/user.dart';
import 'package:app/domain/usecases/footprint/visit_profile_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 足あとを残す操作のプロバイダ
final visitProfileProvider = Provider(
  (ref) => VisitProfileProvider(
    ref.watch(visitProfileUsecaseProvider),
    ref,
  ),
);

class VisitProfileProvider {
  final VisitProfileUsecase _visitProfileUsecase;
  final Ref _ref;
  
  // 処理中のプロフィールIDを記憶（短時間に連続アクセスを防止）
  final Set<String> _processingIds = {};
  
  VisitProfileProvider(this._visitProfileUsecase, this._ref);
  
  Future<void> visitProfile(UserAccount user) async {
    // すでに処理中なら何もしない（連続アクセス防止）
    if (_processingIds.contains(user.userId)) {
      return;
    }
    
    _processingIds.add(user.userId);
    
    try {
      await _visitProfileUsecase.leaveFootprint(user);
      
      // 処理完了後にIDを削除
      _processingIds.remove(user.userId);
    } catch (e) {
      // エラーが発生しても処理中フラグは解除
      _processingIds.remove(user.userId);
      rethrow;
    }
  }
}