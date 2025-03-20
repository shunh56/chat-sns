import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:app/core/utils/debug_print.dart';
import 'package:app/presentation/pages/temp/sound_wave.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

class CallScreen extends ConsumerStatefulWidget {
  const CallScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  late RtcEngine _agoraEngine;

  bool _muted = false;
  bool _speakerOff = false;
  bool _hasVoiceCome = false;
  int? _remoteUid;
  bool _isJoined = false;

  final appId = '828592cf9c2b4a31b5e083a7090a19ad'; // コピーしたアプリID
  final uid = 0; // 参加するユーザーID
  final channelId = 'testChannel'; // 設定したチャネルID（test)
  final token =
      '007eJxTYJA6Xu3ftuGOatSJsxyL0qbMfrXj1LJrwpPvGu/eEqq188ALBQYLIwtTS6PkNMtkoySTRGPDJNNUAwvjRHMDS4NEQ8vEFCO35WkNgYwMBnxqrIwMEAjiczOUpBaXOGck5uWl5jAwAADAAiLk'; // 生成されたトークン

  @override
  void initState() {
    super.initState();
    setupVoiceSDKEngine().onError(
      (error, stackTrace) {
        DebugPrint("error : $error");
        DebugPrint("stackTrace : $stackTrace");
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _agoraEngine.leaveChannel();
  }

  void _onToggleMute() {
    setState(() {
      _muted = !_muted;
    });
    _agoraEngine.muteLocalAudioStream(_muted);
  }

  void _onToggerSpeaker() {
    setState(() {
      _speakerOff = !_speakerOff;
    });
    _agoraEngine.setEnableSpeakerphone(!_speakerOff);
  }

  void _onJoin() async {
    /* 
    //novaの場合
    options = const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      );
    */

    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster, //clientRoleAudience
      channelProfile: ChannelProfileType
          .channelProfileCommunication, //channelProfileCloudGaming channelProfileCommunication1v1 channelProfileGame channelProfileLiveBroadcasting
    );
    try {
      await _agoraEngine.joinChannel(
        token: token,
        channelId: channelId,
        options: options,
        uid: uid,
      );
      DebugPrint("joined channel $channelId !");
    } catch (e) {
      DebugPrint("join error : $e");
    }
  }

  void _onLeave() {
    _agoraEngine.leaveChannel();
  }

  Future<void> setupVoiceSDKEngine() async {
    try {
      // Retrieve or request microphone permission
      await [Permission.microphone].request();

      // Create an instance of the Agora engine
      _agoraEngine = createAgoraRtcEngine();
      await _agoraEngine.initialize(RtcEngineContext(appId: appId));

      // Enables the audioVolumeIndication
      await _agoraEngine.enableAudioVolumeIndication(
          interval: 250, smooth: 8, reportVad: true);

      // Register the event handler
      _agoraEngine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            setState(() {
              _isJoined = true;
            });
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            setState(() {
              _remoteUid = remoteUid;
            });
          },
          onUserOffline: (RtcConnection connection, int remoteUid,
              UserOfflineReasonType reason) {
            setState(() {
              _remoteUid = null;
            });
          },
          onLeaveChannel: (RtcConnection connection, RtcStats stats) {
            setState(() {
              _isJoined = false;
            });
          },
          onAudioVolumeIndication: (
            RtcConnection connection,
            List<AudioVolumeInfo> speakers,
            int speakerNumber,
            int totalVolume,
          ) {
            setState(() {
              _hasVoiceCome = speakers.any((speaker) => speaker.vad == 1);
            });
          },
          onError: (err, msg) => {
            DebugPrint(err.toString()),
            DebugPrint(msg.toString()),
          },
        ),
      );
    } catch (err) {
      DebugPrint(err.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Get started with Voice Calling'),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(height: 40, child: Center(child: _status())),
            Column(
              children: [
                SizedBox(
                  height: 60.0,
                  child: SoundWave(hasVoiceCome: _hasVoiceCome),
                ),
                const SizedBox(height: 40.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _onToggleMute();
                      },
                      child: Icon(
                        _muted ? Icons.mic_off_rounded : Icons.mic_rounded,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _onToggerSpeaker();
                      },
                      child: Icon(
                        _speakerOff
                            ? Icons.volume_off_rounded
                            : Icons.volume_up_rounded,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _onJoin();
                      },
                      child: const Icon(Icons.join_full),
                    ),
                    GestureDetector(
                      onTap: () {
                        _onLeave();
                      },
                      child: const Icon(Icons.exit_to_app),
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _status() {
    String statusText;

    if (!_isJoined) {
      statusText = 'Join a channel';
    } else if (_remoteUid == null) {
      statusText = 'Waiting for a remote user to join...';
    } else {
      statusText = 'Connected to remote user, uid:$_remoteUid';
    }

    return Text(
      statusText,
    );
  }
}
