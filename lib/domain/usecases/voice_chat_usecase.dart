import 'package:app/domain/entity/voice_chat.dart';
import 'package:app/data/repository/voice_chat_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final voiceChatUsecaseProvider = Provider(
  (ref) => VoiceChatUsecase(
    ref.watch(voiceChatRepositoryProvider),
  ),
);

class VoiceChatUsecase {
  final VoiceChatRepository _repository;
  VoiceChatUsecase(this._repository);

  //CREATE
  Future<VoiceChat> createVoiceChat(
    String title, {
    bool isPremium = false,
  }) {
    return _repository.createVoiceChat(title, isPremium: isPremium);
  }

  //READ
  Future<List<VoiceChat>> getFriendsVoiceChats(List<String> userIds) async {
    return _repository.getFriendsVoiceChats(userIds);
  }

  Future<VoiceChat> getVoiceChat(String id) async {
    return _repository.getVoiceChat(id);
  }

  Stream<VoiceChat> streamVoiceChat(String id) {
    return _repository.streamVoiceChat(id);
  }

  //UPDATE
  Future<void> joinVoiceChat(String id, int localId) async {
    return _repository.joinVoiceChat(id, localId);
  }

  Future<void> leaveVoiceChat(String id) async {
    return _repository.leaveVoiceChat(id);
  }

  Future<void> changeMute(String id, bool isMuted) async {
    return _repository.changeMute(id, isMuted);
  }

  //DELETE
  Future<void> quitVoiceChat(String id) async {
    return _repository.quitVoiceChat(id);
  }
}
