import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// チャット入力テキスト用のProvider
final inputTextProvider = StateProvider.autoDispose((ref) => "");

/// テキスト入力コントローラー用のProvider
final controllerProvider =
    Provider.autoDispose((ref) => TextEditingController());

/// スクロールコントローラー用のProvider
final scrollControllerProvider =
    Provider.autoDispose((ref) => ScrollController());

/// メッセージ送信状態管理用のProvider
final messageSendingProvider = StateProvider<bool>((ref) => false);
