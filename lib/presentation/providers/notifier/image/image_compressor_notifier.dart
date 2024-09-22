import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;


final imageCompressorNotifierProvider = Provider(
  (ref) => ImageCompressor(),
);

class ImageCompressor {
  processIconImage(File file) {}

  Future<File?> compressIconImage(File file, String targetPath) async {
/*    final bytes = await file.readAsBytes();
    final originalImage = img.decodeImage(bytes);

    if (originalImage == null) {
      throw Exception('画像の読み込みに失敗しました');
    }

    // 画像を400x400にリサイズ
    final resizedImage = img.copyResize(originalImage, width: 400, height: 400);

    // JPEGとして圧縮（品質は0-100で指定、80は一般的な値）
    final compressedBytes = img.encodeJpg(resizedImage, quality: 80);

    // ファイル名を生成（ユーザーIDと現在時刻を使用）
    final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
 */
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      minWidth: 400,
      minHeight: 400,
      quality: 88,
      keepExif: true,
    );
    if (result == null) {
      return null;
    }
    return File(result.path);
  }

  //postImage
  Future<File?> compressPostImage(File file, String path) async {
    final originalImage = img.decodeImage(file.readAsBytesSync());
    int? width = originalImage?.width;
    int? height = originalImage?.height;
    if (width != null && width > 1000) {
      width = 720;
      height = width ~/ 720;
    }
    width ??= 540;
    height ??= 540;
    int? minWidth;
    int? minHeight;
    if (height > width * 4 / 3) {
      minHeight = 960;
      minWidth = 720;
    } else if (width > height * 4 / 3) {
      minHeight = 720;
      minWidth = 960;
    }

    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      path,
      minWidth: minWidth ?? width,
      minHeight: minHeight ?? height,
      quality: 80,
      keepExif: true,
    );
    if (result == null) {
      return null;
    }
    return File(result.path);
  }
}
