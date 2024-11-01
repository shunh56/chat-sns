import 'package:app/datasource/voice_chat_datasource.dart';
import 'package:app/domain/entity/voice_chat.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final voiceChatRepositoryProvider = Provider(
  (ref) => VoiceChatRepository(
    ref.watch(authProvider),
    ref.watch(voiceChatDatasourceProvider),
  ),
);

class VoiceChatRepository {
  final FirebaseAuth _auth;
  final VoiceChatDatasource _datasource;
  VoiceChatRepository(this._auth, this._datasource);

  //CREATE
  Future<VoiceChat> createVoiceChat(
    String title, {
    bool isPremium = false,
  }) async {
    final json = await _datasource.createVoiceChat(title, isPremium: isPremium);
    return VoiceChat.fromJson(json);
  }

  //READ

  Future<List<VoiceChat>> getFriendsVoiceChats(List<String> userIds) async {
    final res = await _datasource.fetchFriendsVoiceChats(userIds);
    return res.map((doc) => VoiceChat.fromJson(doc.data()!)).toList();
  }

  Future<VoiceChat> getVoiceChat(String id) async {
    final res = await _datasource.fetchVoiceChat(id);
    return VoiceChat.fromJson(res.data()!);
  }

  Stream<VoiceChat> streamVoiceChat(String id) {
    final stream = _datasource.streamVoiceChat(id);
    return stream.map((item) => VoiceChat.fromJson(item.data()!));
  }

  //UPDATE
  Future<void> joinVoiceChat(String id, int localId) async {
    return _datasource.joinVoiceChat(id, localId);
  }

  Future<void> changeMute(String id, bool isMuted) async {
    return _datasource.changeMute(id, isMuted);
  }

  Future<void> leaveVoiceChat(String id) async {
    final voiceChat = await getVoiceChat(id);
    if (voiceChat.adminUsers.contains(_auth.currentUser!.uid) &&
        voiceChat.adminUsers.length == 1) {
      return;
    } else {
      return _datasource.leaveVoiceChat(id);
    }
  }

  //DELETE
  Future<void> quitVoiceChat(String id) async {
    final voiceChat = await getVoiceChat(id);
    if (voiceChat.adminUsers.contains(_auth.currentUser!.uid)) {
      return _datasource.quitVoiceChat(id);
    }
  }
}
