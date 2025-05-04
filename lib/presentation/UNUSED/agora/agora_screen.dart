import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AgoraScreen extends ConsumerStatefulWidget {
  const AgoraScreen({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AgoraScreenState();
}

class _AgoraScreenState extends ConsumerState<AgoraScreen> {
  final AgoraClient client = AgoraClient(
    agoraConnectionData: AgoraConnectionData(
      appId: "828592cf9c2b4a31b5e083a7090a19ad",
      channelName: "testChannel",
      tempToken:
          '007eJxTYJA6Xu3ftuGOatSJsxyL0qbMfrXj1LJrwpPvGu/eEqq188ALBQYLIwtTS6PkNMtkoySTRGPDJNNUAwvjRHMDS4NEQ8vEFCO35WkNgYwMBnxqrIwMEAjiczOUpBaXOGck5uWl5jAwAADAAiLk',
    ),
    enabledPermission: [
      Permission.camera,
      Permission.microphone,
    ],
  );

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  void initAgora() async {
    await client.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              AgoraVideoViewer(client: client),
              AgoraVideoButtons(client: client),
            ],
          ),
        ),
      ),
    );
  }
}
