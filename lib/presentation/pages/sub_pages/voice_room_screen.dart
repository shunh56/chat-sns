import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:app/core/utils/variables.dart';
import 'package:app/presentation/providers/notifier/agora_engine_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceRoomScreen extends ConsumerStatefulWidget {
  const VoiceRoomScreen({super.key, required this.roomId});
  final String roomId;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _VoiceRoomScreenState();
}

class _VoiceRoomScreenState extends ConsumerState<VoiceRoomScreen> {
  late RtcEngine agoraEngine;
  late String token;
  int uid = 0;

  //1. set up
  init() async {
    await _setupVideoSDKEngine();
    await agoraEngine.startPreview();
    token = await ref
        .read(agoraEngineNotifierProvider)
        .fetchToken(uid, widget.roomId);
    agoraEngine.renewToken(token);
  }

  //2. turn online
  activateStream(String token) async {
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      defaultVideoStreamType: VideoStreamType.videoStreamHigh,
    );
    await agoraEngine.joinChannel(
      token: token,
      channelId: token,
      options: options,
      uid: uid,
    );
  }

  //3. quit online
  deactivateStream() async {
    agoraEngine.leaveChannel();
  }

  Future<void> _setupVideoSDKEngine() async {
    await [Permission.microphone, Permission.camera].request();
    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(const RtcEngineContext(appId: agoraId));
    await agoraEngine.enableVideo();
    agoraEngine.enableDualStreamMode(enabled: true);

    // Set audio profile and audio scenario.
    agoraEngine.setAudioProfile(
      profile: AudioProfileType.audioProfileMusicHighQuality,
      scenario: AudioScenarioType.audioScenarioChorus,
    );

    // Set the video configuration
    VideoEncoderConfiguration videoConfig = const VideoEncoderConfiguration(
      mirrorMode: VideoMirrorModeType.videoMirrorModeAuto,
      frameRate: 30,
      bitrate: standardBitrate,
      dimensions: VideoDimensions(width: 1280, height: 720),
      orientationMode: OrientationMode.orientationModeAdaptive,
      degradationPreference: DegradationPreference.maintainQuality,
    );

    // Apply the configuration
    agoraEngine.setVideoEncoderConfiguration(videoConfig);

    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          _setOverView();
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {},
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {},
      ),
    );
  }

  //update firestore
  _setOverView() async {}

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() async {
    super.dispose();
    await agoraEngine.leaveChannel();
    agoraEngine.release();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Center(
                  child: SizedBox(), //_videoPanel(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _videoPanel() {
    /*  // loading agora screen
    if (!previewInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    // when streaming
    if (active) {
      return FadeTransitionWidget(
        child: AgoraVideoView(
          controller: VideoViewController(
            rtcEngine: agoraEngine,
            canvas: const VideoCanvas(uid: 0),
          ),
        ),
      );
    } */
    // before streaming
    return Stack(
      children: [
        Opacity(
          opacity: 0.3,
          child: AgoraVideoView(
            controller: VideoViewController(
              rtcEngine: agoraEngine,
              canvas: const VideoCanvas(uid: 0),
            ),
          ),
        ),
        Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextButton(
                    onPressed: () {
                      activateStream(token);
                    },
                    child: const Text("Activate"),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
