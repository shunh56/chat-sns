import 'package:app/data/datasource/firebase/firebase_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deviceDatasourceProvider = Provider(
  (ref) => DeviceDatasource(
    ref.watch(firestoreProvider),
  ),
);

class DeviceDatasource {
  final FirebaseFirestore _firestore;

  DeviceDatasource(this._firestore);

  /// デバイス情報を登録または更新
  Future<void> setDevice(
    String userId,
    String deviceId,
    Map<String, dynamic> deviceData,
  ) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('devices')
        .doc(deviceId)
        .set(deviceData, SetOptions(merge: true));
  }

  /// ユーザーの全デバイスを取得
  Future<QuerySnapshot<Map<String, dynamic>>> getUserDevices(
    String userId,
  ) async {
    return await _firestore
        .collection('users')
        .doc(userId)
        .collection('devices')
        .orderBy('lastActiveAt', descending: true)
        .get();
  }

  /// アクティブなデバイスのみ取得
  Future<QuerySnapshot<Map<String, dynamic>>> getActiveDevices(
    String userId,
  ) async {
    return await _firestore
        .collection('users')
        .doc(userId)
        .collection('devices')
        .where('isActive', isEqualTo: true)
        .get();
  }

  /// 特定のデバイス情報を取得
  Future<DocumentSnapshot<Map<String, dynamic>>> getDevice(
    String userId,
    String deviceId,
  ) async {
    return await _firestore
        .collection('users')
        .doc(userId)
        .collection('devices')
        .doc(deviceId)
        .get();
  }

  /// デバイス情報を更新
  Future<void> updateDevice(
    String userId,
    String deviceId,
    Map<String, dynamic> updates,
  ) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('devices')
        .doc(deviceId)
        .update(updates);
  }

  /// デバイスを削除
  Future<void> deleteDevice(
    String userId,
    String deviceId,
  ) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('devices')
        .doc(deviceId)
        .delete();
  }

  /// ユーザードキュメントの activeDevices フィールドを更新
  Future<void> updateUserActiveDevices(
    String userId,
    List<Map<String, dynamic>> activeDevices,
  ) async {
    await _firestore.collection('users').doc(userId).update({
      'activeDevices': activeDevices,
      'devicesUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// 古いデバイスを削除 (指定日数以上非アクティブ)
  Future<List<String>> getInactiveDeviceIds(
    String userId,
    Duration inactiveDuration,
  ) async {
    final threshold = Timestamp.fromDate(
      DateTime.now().subtract(inactiveDuration),
    );

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('devices')
        .where('lastActiveAt', isLessThan: threshold)
        .get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }

  /// バッチ処理でデバイスを削除
  Future<void> batchDeleteDevices(
    String userId,
    List<String> deviceIds,
  ) async {
    if (deviceIds.isEmpty) return;

    final batch = _firestore.batch();

    for (final deviceId in deviceIds) {
      final deviceRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('devices')
          .doc(deviceId);
      batch.delete(deviceRef);
    }

    await batch.commit();
  }
}
