import 'package:app/domain/entity/voice_chat.dart';
import 'package:app/presentation/providers/provider/users/friends_notifier.dart';
import 'package:app/usecase/voice_chat_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final vcStreamProvider = StreamProvider.family(
  (ref, String id) => ref.watch(voiceChatUsecaseProvider).streamVoiceChat(id),
);

final voiceChatListNotifierProvider = StateNotifierProvider.autoDispose<
    VoiceChatListNotifier, AsyncValue<List<VoiceChat>>>(
  (ref) => VoiceChatListNotifier(
    ref,
    ref.watch(voiceChatUsecaseProvider),
  )..init(),
);

class VoiceChatListNotifier extends StateNotifier<AsyncValue<List<VoiceChat>>> {
  VoiceChatListNotifier(
    this._ref,
    this._usecase,
  ) : super(
          const AsyncValue.loading(),
        );

  final Ref _ref;

  final VoiceChatUsecase _usecase;

  init() async {
    List<VoiceChat> vcs = [];
    final friendIds = _ref.read(friendIdsProvider);
    if (vcs.isNotEmpty) return;
    vcs = await _usecase.getFriendsVoiceChats(friendIds);
    final uniqueVcs = {for (var vc in vcs) vc.id: vc}.values.toList();
    if (mounted) {
      state = AsyncValue.data(uniqueVcs);
    }
  }

  refresh() async {
    final friendIds = _ref.read(friendIdsProvider);
    final voiceChats = await _usecase.getFriendsVoiceChats(friendIds);
    state = AsyncValue.data(voiceChats);
  }
}
