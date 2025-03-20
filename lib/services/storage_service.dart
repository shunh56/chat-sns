import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef ProgressCallback = void Function(double progress);

final storageServiceProvider = Provider((ref) {
  return StorageService();
});

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // 通常のファイルアップロード
  Future<String> uploadFile(String path, String filePath) async {
    try {
      final file = File(filePath);
      final ref = _storage.ref().child(path);

      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  // 進捗状況を監視しながらファイルをアップロード
  Future<String> uploadFileWithProgress(
    String path,
    String filePath,
    ProgressCallback onProgress,
  ) async {
    try {
      final file = File(filePath);
      final ref = _storage.ref().child(path);

      // アップロードタスクの作成
      final uploadTask = ref.putFile(file);

      // 進捗状況を監視
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress(progress);
      });

      // アップロード完了を待機
      await uploadTask;

      // ダウンロードURLを返す
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  // ファイルの削除
  Future<void> deleteFile(String url) async {
    try {
      // URLからパスを抽出
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }
}
