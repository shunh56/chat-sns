import 'dart:io';
import 'package:app/core/utils/debug_print.dart';
import 'package:app/data/providers/story_providers.dart';
import 'package:app/domain/entity/story/story.dart';
import 'package:app/domain/repository_interface/story_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;

// 画像圧縮用のプロバイダーを作成
final imageCompressorProvider = Provider(
  (ref) => ImageCompressor(),
);

// 画像圧縮クラス
class ImageCompressor {
  // ストーリー用画像の最適化処理
  Future<File?> compressStoryImage(File file) async {
    try {
      // 一時ディレクトリのパスを取得
      final tempDir = await getTemporaryDirectory();
      final targetPath = path.join(tempDir.path,
          'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');

      // 画像の向きを考慮して縦長画像を最適化
      final imageFile = File(file.path);
      final originalImage = img.decodeImage(imageFile.readAsBytesSync());
      // final originalImage = await FlutterImageCompress.decodeBounds(file.path);
      int? minWidth;
      int? minHeight;

      // 縦長の画像かどうかを判定
      bool isPortrait = (originalImage!.height > originalImage.width);

      if (isPortrait) {
        // 縦長画像の場合は縦を優先
        minHeight = 1280; // 最大縦サイズ
        minWidth = 720; // 最大横サイズ
      } else {
        // 横長画像の場合は横を優先
        minHeight = 720; // 最大縦サイズ
        minWidth = 1280; // 最大横サイズ
      }

      // 画像を圧縮
      var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        minWidth: minWidth,
        minHeight: minHeight,
        quality: 85, // ストーリー用なので適度な画質
        rotate: 0, // 元の向きを維持
        keepExif: true, // EXIF情報を維持
        autoCorrectionAngle: true, // 向きを自動修正
      );

      if (result == null) {
        return null;
      }

      return File(result.path);
    } catch (e) {
      DebugPrint('画像の圧縮に失敗しました: $e');
      return null;
    }
  }
}

// アップロードユースケースのプロバイダー
final uploadStoryUsecaseProvider = Provider(
  (ref) => UploadStoryUsecase(
    ref.watch(storyRepositoryProvider),
    ref.watch(imageCompressorProvider),
  ),
);

class UploadStoryUsecase {
  final StoryRepository _storyRepository;
  final ImageCompressor _imageCompressor;

  UploadStoryUsecase(this._storyRepository, this._imageCompressor);

  Future<void> execute({
    required String userId,
    required String localMediaPath,
    String? caption,
    StoryMediaType mediaType = StoryMediaType.image,
    StoryVisibility visibility = StoryVisibility.public,
    List<String> tags = const [],
    String? location,
    bool isSensitiveContent = false,
    Duration expirationDuration = const Duration(hours: 24),
  }) async {
    try {
      // 入力検証
      if (localMediaPath.isEmpty) {
        throw Exception('Media file is required');
      }

      // UUIDの生成
      final storyId = const Uuid().v4();

      // タイムスタンプの生成
      final now = Timestamp.now();
      final expiresAt = Timestamp.fromDate(DateTime.fromMillisecondsSinceEpoch(
          now.millisecondsSinceEpoch + expirationDuration.inMilliseconds));

      // ストーリーオブジェクトの作成
      final story = Story(
        id: storyId,
        userId: userId,
        mediaUrl: '', // 実際のURLは後で設定される
        caption: caption,
        mediaType: mediaType,
        visibility: visibility,
        createdAt: now,
        expiresAt: expiresAt,
        tags: tags,
        location: location,
        isSensitiveContent: isSensitiveContent,
      );

      // 画像の場合は最適化処理を行う
      String finalMediaPath = localMediaPath;
      if (mediaType == StoryMediaType.image) {
        final originalFile = File(localMediaPath);
        final compressedFile =
            await _imageCompressor.compressStoryImage(originalFile);

        // 圧縮に成功した場合は圧縮したファイルを使用
        if (compressedFile != null) {
          finalMediaPath = compressedFile.path;
          DebugPrint(
              '画像を最適化しました: ${originalFile.lengthSync()}バイト → ${compressedFile.lengthSync()}バイト');
        } else {
          DebugPrint('画像の最適化に失敗しました。元のファイルを使用します。');
        }
      }

      // リポジトリを通じてアップロード
      await _storyRepository.uploadStory(story, finalMediaPath);
    } catch (e) {
      DebugPrint('ストーリーのアップロードに失敗しました: $e');
      throw Exception('Failed to upload story: $e');
    }
  }
}
