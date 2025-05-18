import 'dart:convert';

import 'package:app/core/analytics/action_name.dart';
import 'package:app/core/error/failure.dart'; // エラー体系用の新しいimport
import 'package:app/core/utils/flavor.dart';
import 'package:app/core/utils/logger.dart'; // 新しいロガーをインポート
import 'package:app/data/datasource/firebase/firebase_firestore.dart';
import 'package:app/presentation/components/popup/popups/hashtag_popup.dart';
import 'package:app/presentation/pages/profile/subpages/edit_bio_screen.dart';
import 'package:app/presentation/pages/profile/subpages/select_hashtag_screen.dart';
import 'package:app/presentation/providers/session_provider.dart';
import 'package:app/presentation/providers/users/my_user_account_notifier.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/data/datasource/firebase/firebase_auth.dart';
import 'popup_content.dart';

// ポップアップマネージャーのプロバイダー
final popupManagerProvider = Provider((ref) => PopupManager(ref));

class PopupManager {
  final Ref _ref;
  bool _isShowingPopup = false;

  PopupManager(this._ref);

  // アプリ起動時に呼び出して、表示すべきポップアップがあるか確認
  Future<void> checkAndShowPopups(BuildContext context) async {
    if (_isShowingPopup) return;

    try {
      final popups = await _getAvailablePopups();
      if (popups.isEmpty) return;

      // 最優先のポップアップを表示
      _isShowingPopup = true;
      await _showPopup(context, popups.first);
      _isShowingPopup = false;

      // 他のポップアップも連続で表示する場合はここに処理を追加
    } catch (e, stackTrace) {
      Logger.error(
        message: 'Failed to check and show popups',
        error: e,
        stackTrace: stackTrace,
        failure: PopupFailure.unknown(message: e.toString()),
      );
      _isShowingPopup = false;
    }
  }

  // 表示可能なポップアップのリストを取得
  Future<List<PopupContent>> _getAvailablePopups() async {
    final userId = _ref.read(authProvider).currentUser?.uid;
    if (userId == null) return [];

    try {
      // SharedPreferencesからポップアップ表示履歴を取得
      final viewedPopups = await _getViewedPopups();

      final popupsFromMyAccount = getPopupsFromMyAccountData();
      final popupsFromFirestore = await getPopupsFromFirestore();
      final List<PopupContent> availablePopups =
          popupsFromMyAccount + popupsFromFirestore;
      availablePopups.removeWhere((item) => viewedPopups.contains(item.id));

      final List<PopupContent> finalPopups = [];
      for (var popup in availablePopups) {
        if (await popup.shouldDisplay()) {
          finalPopups.add(popup);
        }
      }
      return finalPopups;
    } catch (e, stackTrace) {
      Logger.error(
        message: 'Failed to get available popups',
        error: e,
        stackTrace: stackTrace,
        failure: PopupFailure.retrievalError(message: e.toString()),
      );
      return [];
    }
  }

  List<PopupContent> getPopupsFromMyAccountData() {
    try {
      final List<PopupContent> availablePopups = [];
      final me = _ref.read(myAccountNotifierProvider).asData?.value;
      if (me == null) return [];

      if (me.imageUrl == null || me.imageUrl!.isEmpty) {
        const popupId = "profile_image_missing_popup";
        availablePopups.add(
          HashtagPopup(
            id: popupId,
            // title: "プロフィール画像を設定しよう",
            // description: "あなたらしい画像を設定すると、より多くの人があなたに興味を持ちます",
            imageUrl: 'assets/images/popup/popup_profile_image.svg',
            buttonText: '画像を設定する',
            onPressed: (context) async {
              await _markPopupAsViewed(popupId);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const EditProfileScreens(),
                ),
              );
            },
            dismissible: true,
            displayDuration: const Duration(days: 5),
          ),
        );
      }

      if (me.tags.isEmpty || true) {
        const popupId = "hashtag_missing_popup";

        availablePopups.add(
          HashtagPopup(
            id: popupId,
            // title: "ハッシュタグを追加して他のユーザーと繋がろう",
            // description: "興味のあるハッシュタグを選ぶことで、同じ趣味を持つユーザーを見つけられます",
            imageUrl: 'assets/images/popup/popup_hashtag.svg',
            buttonText: 'ハッシュタグを追加',
            onPressed: (context) async {
              await _markPopupAsViewed(popupId);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const SelectHashtagScreen(),
                ),
              );
            },
            dismissible: true,
            displayDuration: const Duration(days: 7),
          ),
        );
      }

      // 2. プロフィール画像が設定されていないかチェック

      // 3. 自己紹介が設定されていないかチェック
      /*if (me.bio == null || me.bio.isEmpty) {
        final popupId = "bio_missing_popup";
        if (!viewedPopups.contains(popupId)) {
          availablePopups.add(
            HashtagPopup(
              id: popupId,
              title: "自己紹介を書いてみよう",
              description: "自己紹介を書くことで、あなたのことをより多くの人に知ってもらえます",
              imageUrl: 'assets/images/popup/popup_bio.svg',
              buttonText: '自己紹介を書く',
              onPressed: (context) async {
                await _markPopupAsViewed(popupId);
                // 自己紹介設定画面へナビゲーション
                // Navigator.pushReplacement...
              },
              dismissible: true,
              displayDuration: Duration(days: 3),
            ),
          );
        }
      } */

      // 4. その他の必要な情報チェック（例: 場所、年齢など）

      return availablePopups;
    } catch (e, stackTrace) {
      Logger.error(
        message: 'Failed to get popups from user account data',
        error: e,
        stackTrace: stackTrace,
        failure: PopupFailure.userDataError(message: e.toString()),
      );
      return [];
    }
  }

  Future<List<PopupContent>> getPopupsFromFirestore() async {
    return [];
    /*
    final firestore = _ref.read(firestoreProvider);
    final List<PopupContent> availablePopups = [];
  
    try {
      final popupsSnapshot = await firestore.collection(...).get();
    } catch (e) {
      Logger.error(
        message: 'Failed to get popups from Firestore',
        error: e,
        stackTrace: stackTrace,
        failure: PopupFailure.firestoreError(message: e.toString()),
      );
      return availablePopups;
    }
    return availablePopups;
    */
  }

  // ポップアップを表示する
  Future<void> _showPopup(BuildContext context, PopupContent popup) async {
    try {
      _ref
          .read(sessionStateProvider.notifier)
          .trackAction(ActionName.popup_hashtag.value);

      return showDialog<void>(
        context: context,
        barrierDismissible: popup.dismissible,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: popup,
          );
        },
      ).then((_) {
        // ポップアップが閉じられた時の処理
        _markPopupAsViewed(popup.id);
      });
    } catch (e, stackTrace) {
      Logger.error(
        message: 'Failed to show popup',
        error: e,
        stackTrace: stackTrace,
        failure: PopupFailure.displayError(message: e.toString()),
      );
    }
  }

  // ポップアップの表示履歴を取得（72時間以内のもののみ）
  Future<List<String>> _getViewedPopups() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // JSONとして保存されたマップ（ポップアップID : タイムスタンプ）を取得
      final String viewedPopupsJson =
          prefs.getString('viewed_popups_timestamps') ?? '{}';
      Map<String, dynamic> viewedPopupsMap = {};

      try {
        viewedPopupsMap = jsonDecode(viewedPopupsJson) as Map<String, dynamic>;
      } catch (e, stackTrace) {
        Logger.error(
          message: 'Failed to decode viewed popups JSON',
          error: e,
          stackTrace: stackTrace,
          failure: PopupFailure.storageError(message: e.toString()),
        );
        return [];
      }

      // 現在の時刻を取得
      final now = DateTime.now().millisecondsSinceEpoch;
      // 72時間 = 259,200,000 ミリ秒
      const duration72Hours = 72 * 60 * 60 * 1000;

      // 72時間以内に表示されたポップアップIDのリストを作成
      final List<String> recentlyViewedPopups = [];

      viewedPopupsMap.forEach((popupId, timestampMillis) {
        // タイムスタンプをintとして扱う
        final timestamp = int.tryParse(timestampMillis.toString()) ?? 0;
        // 現在時刻と表示時刻の差が72時間未満なら、まだ「最近見た」と判断
        if (now - timestamp < duration72Hours && Flavor.isProdEnv) {
          recentlyViewedPopups.add(popupId);
        }
      });

      Logger.debug(
        message:
            'Recently viewed popups in the last 72 hours: $recentlyViewedPopups',
      );
      return recentlyViewedPopups;
    } catch (e, stackTrace) {
      Logger.error(
        message: 'Failed to get viewed popups',
        error: e,
        stackTrace: stackTrace,
        failure: PopupFailure.storageError(message: e.toString()),
      );
      return [];
    }
  }

  // ポップアップを既読としてマーク（タイムスタンプ付き）
  Future<void> _markPopupAsViewed(String popupId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 既存のマップを読み込む
      final String viewedPopupsJson =
          prefs.getString('viewed_popups_timestamps') ?? '{}';
      Map<String, dynamic> viewedPopupsMap = {};

      try {
        viewedPopupsMap = jsonDecode(viewedPopupsJson) as Map<String, dynamic>;
      } catch (e, stackTrace) {
        Logger.error(
          message: 'Failed to decode JSON when marking popup as viewed',
          error: e,
          stackTrace: stackTrace,
          failure: PopupFailure.storageError(message: e.toString()),
        );
        viewedPopupsMap = {};
      }

      // 現在の時刻をミリ秒で記録
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      viewedPopupsMap[popupId] = timestamp;

      // 更新したマップをJSONとして保存
      await prefs.setString(
          'viewed_popups_timestamps', jsonEncode(viewedPopupsMap));

      // 後方互換性のために古いキーも更新（必要なければ削除可）
      final viewedPopupsList = viewedPopupsMap.keys.toList();
      await prefs.setStringList('viewed_popups', viewedPopupsList);

      // Firestoreにも記録
      final userId = _ref.read(authProvider).currentUser?.uid;
      if (userId != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('viewedPopups')
            .doc(popupId)
            .set({
          'viewedAt': FieldValue.serverTimestamp(),
          'expiresAt': Timestamp.fromDate(
            DateTime.now().add(const Duration(hours: 72)),
          ),
        });
      }
    } catch (e, stackTrace) {
      Logger.error(
        message: 'Failed to mark popup as viewed',
        error: e,
        stackTrace: stackTrace,
        failure: PopupFailure.storageError(message: e.toString()),
      );
    }
  }
}
