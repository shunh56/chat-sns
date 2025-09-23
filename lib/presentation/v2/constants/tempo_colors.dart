import 'package:flutter/material.dart';

/// Tempoアプリの色定義
/// UI/UXドキュメントに基づいた色彩システム
class TempoColors {
  // Primary Brand Colors - 温かみと信頼感
  static const primary = Color(0xFF6366F1);      // Indigo - 信頼と深み
  static const primaryLight = Color(0xFF818CF8);
  static const secondary = Color(0xFFEC4899);    // Pink - 感情と共感
  static const accent = Color(0xFFF59E0B);       // Amber - 活力と希望
  
  // Surface Colors - 奥行きと階層
  static const background = Color(0xFF0F0F17);    // 深い紫がかった背景（ダークモード）
  static const backgroundLight = Color(0xFFFAFAFC); // 明るい背景（ライトモード）
  static const surface = Color(0xFF18181F);       // カード背景（ダーク）
  static const surfaceLight = Color(0xFFFFFFFF);  // カード背景（ライト）
  static const surfaceElevated = Color(0xFF1F1F28); // 浮いた要素
  
  // Text Colors - 読みやすさと階層
  static const textPrimary = Color(0xFFF8FAFC);   // 主要テキスト（ダーク）
  static const textPrimaryLight = Color(0xFF0F172A); // 主要テキスト（ライト）
  static const textSecondary = Color(0xFF94A3B8);  // 補助テキスト
  static const textTertiary = Color(0xFF64748B);   // 三次テキスト
  
  // Status Colors - 感情と状態を表現
  static const success = Color(0xFF22C55E);       // 成功・つながり
  static const warning = Color(0xFFFBBF24);       // 警告・タイマー
  static const danger = Color(0xFFEF4444);        // エラー・期限
  static const online = Color(0xFF10B981);        // オンライン状態
  
  // Mood Colors（感情に基づいた色設計）
  static const moodHappy = Color(0xFFFFD700);     // 😊 - 金色の喜び
  static const moodTired = Color(0xFF6B7280);     // 😪 - 灰色の疲労
  static const moodCool = Color(0xFF06B6D4);      // 😎 - 青の冷静
  static const moodSad = Color(0xFF8B5CF6);       // 🥺 - 紫の切なさ
  static const moodAngry = Color(0xFFEF4444);     // 😤 - 赤の怒り
  static const moodThinking = Color(0xFFF59E0B);  // 🤔 - 橙の思考
  
  // Gradient Helpers
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );
  
  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, secondary],
  );
  
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [success, primary],
  );
}