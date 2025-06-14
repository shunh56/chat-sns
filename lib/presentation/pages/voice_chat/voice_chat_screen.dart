import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:app/core/extenstions/int_extension.dart';
import 'package:app/core/utils/debug_print.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/core/utils/variables.dart';
import 'package:app/domain/entity/user.dart';
import 'package:app/domain/entity/voice_chat.dart';
import 'package:app/presentation/components/core/shader.dart';
import 'package:app/presentation/components/dialogs/voice_chat_dialogs.dart';
import 'package:app/presentation/components/image/user_icon.dart';
import 'package:app/presentation/providers/chats/voice_chats_list.dart';
import 'package:app/data/datasource/firebase/firebase_auth.dart';
import 'package:app/data/datasource/firebase/firebase_funcrtions.dart';
import 'package:app/presentation/providers/users/all_users_notifier.dart';
import 'package:app/presentation/providers/state/count_down.dart';
import 'package:app/domain/usecases/voice_chat_usecase.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:permission_handler/permission_handler.dart';

final poppedProvider = StateProvider.autoDispose((ref) => false);
final isLoadingProvider = StateProvider.autoDispose((ref) => true);
final animationDoneProvider = StateProvider.autoDispose((ref) => false);
final maxNumExceededProvider = StateProvider.autoDispose((ref) => false);

final isSpeakerProvider = StateProvider.autoDispose((ref) => false);
final speakerListProvider = StateProvider.autoDispose<List<int>>((ref) => []);
//final localUidProvider = StateProvider.autoDispose((ref) => -1);
//final speakerUidProvider = StateProvider.autoDispose((ref) => -1);

class VoiceChatScreen extends ConsumerWidget {
  const VoiceChatScreen({super.key, required this.id, this.uuid = ""});
  final String id;
  final String uuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewPadding.bottom,
          ),
          child: Column(
            children: [
              VoiceChatAppBar(
                id: id,
                uuid: uuid,
              ),
              Expanded(
                child: VoiceChatFeed(
                  id: id,
                  uuid: uuid,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VoiceChatAppBar extends ConsumerWidget {
  const VoiceChatAppBar({super.key, required this.id, required this.uuid});
  final String id;
  final String uuid;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final vcStream = ref.watch(vcStreamProvider(id));
    final countdown = ref.watch(countdownProvider);
    final popped = ref.watch(poppedProvider);
    void leave() async {
      if (!popped) {
        if (uuid.isNotEmpty) {
          await FlutterCallkitIncoming.endCall(uuid);
        }
        await Future.delayed(const Duration(milliseconds: 100));
        ref.read(poppedProvider.notifier).state = true;
        ref.read(voiceChatUsecaseProvider).leaveVoiceChat(id);
        Navigator.pop(context);
      }
    }

    return vcStream.when(
      data: (vc) {
        if (countdown.isNegative) {
          leave();
        } else {
          ref
              .read(countdownProvider.notifier)
              .startCountdown(vc.endAt.toDate());
        }

        return AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            vc.title,
          ),
          actions: [
            const Text(
              "終了まで",
            ),
            const Gap(4),
            GestureDetector(
              onTap: () {
                leave();
              },
              child: Text(
                // vc.endAt.toTimeStr,
                '${countdown.inHours.autoZero}:${countdown.inMinutes.remainder(60).autoZero}:${countdown.inSeconds.remainder(60).autoZero}',
              ),
            ),
            Gap(themeSize.horizontalPadding),
          ],
        );
      },
      error: (e, s) => Center(
        child: Text("ERROR : $e"),
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class VoiceChatFeed extends ConsumerStatefulWidget {
  const VoiceChatFeed({super.key, required this.id, required this.uuid});
  final String id;
  final String uuid;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _VoiceChatFeedState();
}

class _VoiceChatFeedState extends ConsumerState<VoiceChatFeed> {
  bool joined = false;
  late RtcEngine _agoraEngine;

  @override
  void dispose() {
    super.dispose();
    DebugPrint(_agoraEngine.runtimeType);
    _agoraEngine.leaveChannel();
  }

  changeMute(bool before) {
    _agoraEngine.muteLocalAudioStream(!before);
    ref.read(voiceChatUsecaseProvider).changeMute(widget.id, !before);
  }

  changeSpeaker(bool before) {
    _agoraEngine.setEnableSpeakerphone(!before);
    ref.read(isSpeakerProvider.notifier).state = !before;
  }

  Future<void> setupVoiceSDKEngine(VoiceChat vc) async {
    joined = true;
    await Future.delayed(const Duration(milliseconds: 30));
    if (vc.joinedUsers.length >= vc.maxCount * 2 &&
        !vc.joinedUsers.contains(ref.read(authProvider).currentUser!.uid)) {
      ref.read(maxNumExceededProvider.notifier).state = true;
      ref.read(isLoadingProvider.notifier).state = false;
      await Future.delayed(const Duration(milliseconds: 400));
      ref.read(animationDoneProvider.notifier).state = true;
      return;
    }

    final HttpsCallable callable =
        ref.read(httpsCallableProvider).agoraTokenGenerator();

    try {
      // Retrieve or request microphone permission
      await [Permission.microphone].request();

      final result = await callable.call({
        'channelName': widget.id,
        'uid': 0,
      });

      final token = result.data['token'];
      // Create an instance of the Agora engine
      _agoraEngine = createAgoraRtcEngine();
      await _agoraEngine.initialize(
        const RtcEngineContext(appId: agoraId),
      );

      // Enables the audioVolumeIndication
      await _agoraEngine.enableAudioVolumeIndication(
          interval: 250, smooth: 8, reportVad: true);

      ChannelMediaOptions options = const ChannelMediaOptions(
        clientRoleType:
            ClientRoleType.clientRoleBroadcaster, //clientRoleAudience
        channelProfile: ChannelProfileType
            .channelProfileCommunication, //channelProfileCloudGaming channelProfileCommunication1v1 channelProfileGame channelProfileLiveBroadcasting
      );
      try {
        await _agoraEngine.joinChannel(
          token: token,
          channelId: widget.id,
          options: options,
          uid: 0,
        );
      } catch (e) {
        DebugPrint("join error : $e");
      }

      // Register the event handler
      _agoraEngine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) async {
            final localId = connection.localUid!;
            if (mounted) {
              //ref.read(localUidProvider.notifier).state = localId;
              ref
                  .read(voiceChatUsecaseProvider)
                  .joinVoiceChat(widget.id, localId);
              ref.read(isLoadingProvider.notifier).state = false;
              await Future.delayed(const Duration(milliseconds: 400));
              ref.read(animationDoneProvider.notifier).state = true;
            }
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            // showMessage("user joined : $remoteUid");
          },
          // onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          //  leave();
          // },
          onAudioVolumeIndication: (
            RtcConnection connection,
            List<AudioVolumeInfo> speakers,
            int speakerNumber,
            int totalVolume,
          ) {
            final speakerUids = speakers
                .where((item) => (item.volume ?? 0) > 0)
                .map((speaker) => speaker.uid!)
                .toList();
            if (mounted) {
              if (speakerUids.isNotEmpty) {
                ref.read(speakerListProvider.notifier).state = speakerUids;
              }
            }
          },
          onError: (err, msg) => {
            DebugPrint(err.toString()),
            DebugPrint(msg.toString()),
          },
        ),
      );
    } catch (err) {
      DebugPrint("initialization error $err");
    }
  }

  void leave() async {
    final popped = ref.read(poppedProvider);
    if (mounted) {
      if (!popped) {
        if (widget.uuid.isNotEmpty) {
          await FlutterCallkitIncoming.endCall(widget.uuid);
        }
        ref.read(poppedProvider.notifier).state = true;
        ref.read(voiceChatUsecaseProvider).leaveVoiceChat(widget.id);
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final vcStream = ref.watch(vcStreamProvider(widget.id));

    final screen = vcStream.when(
      data: (vc) {
        if (!joined) {
          setupVoiceSDKEngine(vc);
        }

        return FutureBuilder(
          future: ref
              .read(allUsersNotifierProvider.notifier)
              .getUserAccounts(vc.joinedUsers),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            final users = snapshot.data!;

            return _buildTiles(context, ref, vc, users);
          },
        );
      },
      error: (e, s) => Center(
        child: Text("ERROR : $e"),
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    return Stack(
      children: [
        screen,
        if (!ref.watch(animationDoneProvider))
          AnimatedOpacity(
            opacity: ref.watch(isLoadingProvider) ? 1 : 0,
            duration: const Duration(milliseconds: 400),
            child: ShaderWidget(
              child: Container(
                width: MediaQuery.sizeOf(context).width,
                height: MediaQuery.sizeOf(context).height,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "ローディング中",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Gap(12),
                    CircularProgressIndicator(
                      strokeWidth: 1.2,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (ref.watch(maxNumExceededProvider))
          ShaderWidget(
            child: Container(
              width: MediaQuery.sizeOf(context).width,
              height: MediaQuery.sizeOf(context).height,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
              ),
              child: Center(
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: themeSize.horizontalPaddingLarge,
                  ),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: ThemeColor.stroke.withOpacity(0.7),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "定員に満たしています。",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Gap(24),
                      GestureDetector(
                        onTap: () async {
                          Navigator.pop(context);
                        },
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: ThemeColor.subText,
                            ),
                            child: const Text(
                              "退出する",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  _buildTiles(BuildContext context, WidgetRef ref, VoiceChat vc,
      List<UserAccount> users) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final isMuted =
        vc.userInfo[ref.read(authProvider).currentUser!.uid]?.isMuted ?? false;
    final isSpeaker = ref.watch(isSpeakerProvider);
    final speakers = ref.watch(speakerListProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        users.length <= 4
            ? Expanded(
                child: Column(
                  children: users
                      .map(
                        (user) => Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: ThemeColor.accent,
                              border: (user.userId ==
                                      ref.read(authProvider).currentUser!.uid)
                                  ? speakers.contains(0)
                                      ? Border.all(
                                          color: Colors.cyan,
                                        )
                                      : null
                                  : speakers.contains(
                                          (vc.userInfo[user.userId]!.uid))
                                      ? Border.all(
                                          color: Colors.cyan,
                                        )
                                      : null,
                            ),
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Center(
                                  child: UserIcon(
                                    user: user,
                                    r: 80,
                                 
                                  ),
                                ),
                                Positioned(
                                  bottom: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      color: ThemeColor.background,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (vc.userInfo[user.userId]!.isMuted)
                                          const Padding(
                                            padding: EdgeInsets.only(right: 4),
                                            child: Icon(
                                              Icons.mic_off,
                                              color: Colors.white,
                                              size: 14,
                                            ),
                                          ),
                                        Text(user.name),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              )
            : Expanded(
                child: Column(
                  children: (() {
                    final List<Widget> list = [];
                    for (int i = 0; i < users.length; i = i + 2) {
                      list.add(
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: ThemeColor.accent,
                                      border: (users[i].userId ==
                                              ref
                                                  .read(authProvider)
                                                  .currentUser!
                                                  .uid)
                                          ? speakers.contains(0)
                                              ? Border.all(
                                                  color: Colors.cyan,
                                                )
                                              : null
                                          : speakers.contains((vc
                                                  .userInfo[users[i].userId]!
                                                  .uid))
                                              ? Border.all(
                                                  color: Colors.cyan,
                                                )
                                              : null,
                                    ),
                                    child: Stack(
                                      alignment: Alignment.bottomCenter,
                                      children: [
                                        Center(
                                          child: UserIcon(
                                            user: users[i],
                                        r: 64,
                                          
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 12,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              color: ThemeColor.background,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                if (vc
                                                    .userInfo[users[i].userId]!
                                                    .isMuted)
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                        right: 4),
                                                    child: Icon(
                                                      Icons.mic_off,
                                                      color: Colors.white,
                                                      size: 14,
                                                    ),
                                                  ),
                                                Text(users[i].name),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const Gap(8),
                                ((i + 1) < users.length)
                                    ? Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            color: ThemeColor.accent,
                                            border: (users[i + 1].userId ==
                                                    ref
                                                        .read(authProvider)
                                                        .currentUser!
                                                        .uid)
                                                ? speakers.contains(0)
                                                    ? Border.all(
                                                        color: Colors.cyan,
                                                      )
                                                    : null
                                                : speakers.contains((vc
                                                        .userInfo[users[i + 1]
                                                            .userId]!
                                                        .uid))
                                                    ? Border.all(
                                                        color: Colors.cyan,
                                                      )
                                                    : null,
                                          ),
                                          child: Stack(
                                            alignment: Alignment.bottomCenter,
                                            children: [
                                              Center(
                                                child: UserIcon(
                                                  user: users[i + 1],
                                                r: 64,
                                                
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 12,
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 24,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            100),
                                                    color:
                                                        ThemeColor.background,
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      if (vc
                                                          .userInfo[users[i + 1]
                                                              .userId]!
                                                          .isMuted)
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  right: 4),
                                                          child: Icon(
                                                            Icons.mic_off,
                                                            color: Colors.white,
                                                            size: 14,
                                                          ),
                                                        ),
                                                      Text(users[i + 1].name),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : const Expanded(
                                        child: SizedBox(),
                                      ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    return list;
                  })(),
                ),
              ),
        const Gap(4),
        Container(
          margin: EdgeInsets.symmetric(horizontal: themeSize.horizontalPadding),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: ThemeColor.accent,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  changeMute(isMuted);
                },
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Icon(
                    isMuted ? Icons.mic_off_outlined : Icons.mic,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  ref.read(isSpeakerProvider.notifier).state = !isSpeaker;
                },
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Icon(
                    ref.watch(isSpeakerProvider)
                        ? Icons.volume_up_rounded
                        : Icons.volume_off_outlined,
                  ),
                ),
              ),
              CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.2),
                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                ),
              ),
              GestureDetector(
                onTap: () {
                  VoiceChatDialogs(context).showExitVoiceChatDialog(
                    widget.id,
                    leave,
                  );
                },
                child: CircleAvatar(
                  backgroundColor: Colors.red.withOpacity(0.7),
                  child: const Icon(
                    Icons.call_end,
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
