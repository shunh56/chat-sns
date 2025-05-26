// lib/presentation/pages/posts/shared/components/text/linkified_text.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// リンク、ハッシュタグ、メンションに対応した高機能テキストコンポーネント
/// 既存のBuildTextクラスの機能を統合し、拡張
class LinkifiedText extends StatelessWidget {
  const LinkifiedText({
    super.key,
    required this.text,
    this.style,
    this.linkStyle,
    this.hashtagStyle,
    this.mentionStyle,
    this.maxLines,
    this.overflow,
    this.isDynamicSize = false,
    this.onLinkTap,
    this.onHashtagTap,
    this.onMentionTap,
  });

  final String text;
  final TextStyle? style;
  final TextStyle? linkStyle;
  final TextStyle? hashtagStyle;
  final TextStyle? mentionStyle;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool isDynamicSize;
  final Function(String)? onLinkTap;
  final Function(String)? onHashtagTap;
  final Function(String)? onMentionTap;

  // パターン定義
  static final _urlPattern = RegExp(
    r'https?:\/\/([\w-]+\.)+[\w-]+(\/[\w- .\/?%&=]*)?',
    caseSensitive: false,
  );
  
  static final _hashtagPattern = RegExp(
    r'#[a-zA-Z0-9_\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF]+',
  );
  
  static final _mentionPattern = RegExp(r'@[a-zA-Z0-9_]+');

  @override
  Widget build(BuildContext context) {
    final textConfig = _getTextConfig();
    final spans = _buildTextSpans(textConfig);

    return RichText(
      text: TextSpan(children: spans),
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
    );
  }

  _TextConfig _getTextConfig() {
    if (!isDynamicSize) {
      return const _TextConfig(
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        lineHeight: 1.4,
      );
    }

    // 動的サイズ計算（BuildTextの機能を統合）
    final length = text.replaceAll(_urlPattern, '').length;
    
    if (length <= 10) {
      return const _TextConfig(
        fontSize: 24.0,
        fontWeight: FontWeight.w600,
        lineHeight: 1.3,
      );
    } else if (length <= 30) {
      return const _TextConfig(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
        lineHeight: 1.3,
      );
    } else if (length <= 100) {
      return const _TextConfig(
        fontSize: 16.0,
        fontWeight: FontWeight.w500,
        lineHeight: 1.5,
      );
    } else {
      return const _TextConfig(
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
        lineHeight: 1.5,
      );
    }
  }

  List<TextSpan> _buildTextSpans(_TextConfig config) {
    final spans = <TextSpan>[];
    final allMatches = <_Match>[];

    // すべてのパターンマッチを収集
    _collectMatches(allMatches);
    allMatches.sort((a, b) => a.start.compareTo(b.start));

    int currentIndex = 0;
    for (final match in allMatches) {
      // マッチ前のテキスト
      if (match.start > currentIndex) {
        spans.add(_buildNormalTextSpan(
          text.substring(currentIndex, match.start),
          config,
        ));
      }

      // マッチしたテキスト
      spans.add(_buildMatchSpan(match, config));
      currentIndex = match.end;
    }

    // 残りのテキスト
    if (currentIndex < text.length) {
      spans.add(_buildNormalTextSpan(
        text.substring(currentIndex),
        config,
      ));
    }

    return spans;
  }

  void _collectMatches(List<_Match> allMatches) {
    // URL
    allMatches.addAll(
      _urlPattern.allMatches(text).map(
        (match) => _Match(
          match.start,
          match.end,
          _MatchType.url,
          match.group(0)!,
        ),
      ),
    );

    // ハッシュタグ
    allMatches.addAll(
      _hashtagPattern.allMatches(text).map(
        (match) => _Match(
          match.start,
          match.end,
          _MatchType.hashtag,
          match.group(0)!,
        ),
      ),
    );

    // メンション
    allMatches.addAll(
      _mentionPattern.allMatches(text).map(
        (match) => _Match(
          match.start,
          match.end,
          _MatchType.mention,
          match.group(0)!,
        ),
      ),
    );
  }

  TextSpan _buildNormalTextSpan(String text, _TextConfig config) {
    return TextSpan(
      text: text,
      style: (style ?? const TextStyle()).copyWith(
        fontSize: config.fontSize,
        fontWeight: config.fontWeight,
        height: config.lineHeight,
        color: Colors.white,
      ),
    );
  }

  TextSpan _buildMatchSpan(_Match match, _TextConfig config) {
    switch (match.type) {
      case _MatchType.url:
        return TextSpan(
          text: match.text,
          style: linkStyle ?? TextStyle(
            fontSize: isDynamicSize ? (config.fontSize - 2).clamp(12.0, 16.0) : 14.0,
            fontWeight: FontWeight.w500,
            height: config.lineHeight,
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () => _handleLinkTap(match.text),
        );

      case _MatchType.hashtag:
        return TextSpan(
          text: match.text,
          style: hashtagStyle ?? TextStyle(
            fontSize: config.fontSize,
            fontWeight: FontWeight.w500,
            height: config.lineHeight,
            color: Colors.blue,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () => _handleHashtagTap(match.text.substring(1)),
        );

      case _MatchType.mention:
        return TextSpan(
          text: match.text,
          style: mentionStyle ?? TextStyle(
            fontSize: config.fontSize,
            fontWeight: FontWeight.w500,
            height: config.lineHeight,
            color: Colors.blue,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () => _handleMentionTap(match.text.substring(1)),
        );
    }
  }

  void _handleLinkTap(String url) {
    if (onLinkTap != null) {
      onLinkTap!(url);
    } else {
      _launchUrl(url);
    }
  }

  void _handleHashtagTap(String hashtag) {
    if (onHashtagTap != null) {
      onHashtagTap!(hashtag);
    }
  }

  void _handleMentionTap(String mention) {
    if (onMentionTap != null) {
      onMentionTap!(mention);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

/// テキスト設定を保持するクラス
class _TextConfig {
  final double fontSize;
  final FontWeight fontWeight;
  final double lineHeight;

  const _TextConfig({
    required this.fontSize,
    required this.fontWeight,
    required this.lineHeight,
  });
}

/// マッチ情報を保持するクラス
class _Match {
  final int start;
  final int end;
  final _MatchType type;
  final String text;

  _Match(this.start, this.end, this.type, this.text);
}

/// マッチタイプ
enum _MatchType { url, hashtag, mention }