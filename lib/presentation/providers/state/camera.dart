// Package imports:
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:

/// Provider
final cameraNotifierProvider = StateNotifierProvider.autoDispose<
    CameraNotifierProvider, AsyncValue<CameraController>>((ref) {
  return CameraNotifierProvider(ref)..initialize();
});

/// State
class CameraNotifierProvider
    extends StateNotifier<AsyncValue<CameraController>> {
  CameraNotifierProvider(this.ref)
      : super(const AsyncValue<CameraController>.loading());
  final Ref ref;
  late List<CameraDescription> cameras;
  late CameraController cameraController;

  int index = 1;

  Future<void> initialize() async {
    try {
      cameras = await availableCameras();
      cameraController = CameraController(
        cameras[index],
        ResolutionPreset.max,
        enableAudio: false,
      );
      await cameraController.initialize();
      await cameraController.setFlashMode(FlashMode.off);
      state = AsyncValue.data(cameraController);
      ref.onDispose(() {
        cameraController.dispose();
      });
    } on CameraException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    } catch (e) {
      // その他の例外
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  switchCamera() async {
    if (index == 0) {
      index = 1;
    } else {
      index = 0;
    }
    await cameraController.setDescription(cameras[index]);
    await cameraController.setFlashMode(FlashMode.off);
    //await cameraController.initialize();
    state = AsyncValue.data(cameraController);
  }
}
