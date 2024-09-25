import 'dart:io';

import 'package:app/core/utils/debug_print.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/domain/entity/pov.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/providers/notifier/image/image_compressor_notifier.dart';
import 'package:app/presentation/providers/state/camera.dart';
import 'package:app/usecase/pov_usecase.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class CreatePovScreen extends ConsumerWidget {
  const CreatePovScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final state = ref.watch(povStateProvider);
    final imageNotifier = ref.watch(povImageFileProvider.notifier);
    final textNotifier = ref.watch(povTextProvider.notifier);
    final cameraState = ref.watch(cameraNotifierProvider);
    final widget = cameraState.when(
      // 撮影プレビュー
      data: (camera) {
        final image = state.imageFile;
        DebugPrint("aspect ratio : ${camera.value.aspectRatio}");
        return (image != null)
            ? Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: SizedBox(
                            width: themeSize.screenWidth,
                            height: themeSize.screenHeight,
                            child: Image.file(
                              File(image.path),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () {
                              imageNotifier.state = null;
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withOpacity(0.3),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: const Icon(
                                Icons.close_rounded,
                                color: ThemeColor.white,
                                size: 20,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Positioned(
                    right: 24,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                    child: GestureDetector(
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        if (state.isReadyToUpload) {
                          ref.read(povUsecaseProvider).uploadPov(state);
                          Navigator.pop(context);
                        } else {
                          showMessage("DATA NOT READY");
                        }
                      },
                      onLongPress: () async {
                        HapticFeedback.lightImpact();
                        textNotifier.state = "test : ${DateTime.now()}";
                        await ref.read(povUsecaseProvider).uploadPov(state);
                       
                        Navigator.pop(context);
                      },
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.cyan.withOpacity(0.5),
                        child: const Center(
                          child: Icon(
                            Icons.send,
                            color: ThemeColor.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Container(
                margin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      width: themeSize.screenWidth,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      child: AspectRatio(
                        aspectRatio:
                            (themeSize.screenWidth / themeSize.screenHeight),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: FittedBox(
                            alignment: Alignment.center,
                            fit: BoxFit.fitHeight,
                            child: SizedBox(
                              width: themeSize.screenWidth,
                              height: themeSize.screenWidth *
                                  camera.value.aspectRatio,
                              child: CameraPreview(camera),
                            ),
                          ),
                        ),
                      ),
                    ),
                    /*  ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Transform.scale(
                        scale: 1,
                        child: CameraPreview(camera),
                      ),
                    ), */
                    // const Expanded(child: SizedBox()),
                    Positioned(
                      bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                      width: themeSize.screenWidth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Expanded(child: SizedBox()),
                          Center(
                            child: GestureDetector(
                              onTap: () async {
                                try {
                                  final file = await camera.takePicture();
                                  final imageFile = File(file.path);
                                  Timestamp now = Timestamp.now();
                                  var directory =
                                      await getApplicationDocumentsDirectory();
                                  var path = '${directory.path}/$now.jpg';
                                  final compressedFile = await ref
                                      .read(imageCompressorNotifierProvider)
                                      .compressPostImage(imageFile, path);

                                  imageNotifier.state = compressedFile!;
                                  textNotifier.state =
                                      "POSTED AT ${now.toDate()}";
                                } catch (e) {
                                  showMessage("taking photo failed : $e");
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    width: 2,
                                    color: ThemeColor.white,
                                  ),
                                ),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: const BoxDecoration(
                                    color: ThemeColor.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    ref
                                        .read(cameraNotifierProvider.notifier)
                                        .switchCamera();
                                  },
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: ThemeColor.white.withOpacity(0.1),
                                    ),
                                    child: const Icon(
                                      Icons.sync_outlined,
                                      color: ThemeColor.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 24,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
      },
      error: (e, s) {
        return Center(
          child: Container(
            padding: const EdgeInsets.only(
              top: 36,
              bottom: 16,
              left: 24,
              right: 24,
            ),
            margin: const EdgeInsets.only(
              bottom: 100,
              left: 12,
              right: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(
                8,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.camera_alt_outlined,
                  color: ThemeColor.white,
                  size: 36,
                ),
                const SizedBox(
                  height: 8,
                ),
                const Text(
                  'カメラへのアクセスを許可',
                ),
                const SizedBox(
                  height: 16,
                ),
                const Text(
                  '写真のシェアや動画の撮影が可能になります。',
                ),
                const SizedBox(
                  height: 24,
                ),
                Material(
                  borderRadius: BorderRadius.circular(100),
                  color: ThemeColor.white,
                  child: InkWell(
                    splashColor: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(100.0),
                    onTap: () {
                      Navigator.pop(context);
                      openAppSettings();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: const Text(
                        "設定画面へ",
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      // 読込中プログレス
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text("Povを作成"),
      ),
      body: SafeArea(
        child: widget,
      ),
    );
  }
}
