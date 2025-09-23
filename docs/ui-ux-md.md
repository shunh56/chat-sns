# ui-ux.md - Tempo UI/UX設計書（v2.0）

## 🎨 洗練されたデザインシステム

### デザイン哲学
1. **Organic Flow** - 自然で有機的な流れ
2. **Gentle Presence** - 優しい存在感
3. **Temporal Beauty** - 時間の美しさを表現
4. **Authentic Connection** - 本物の繋がりを演出
5. **Effortless Interaction** - 努力を感じさせない操作

### カラーシステム（完全リニューアル）

```dart
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
  
  // Gradient Definitions
  static const primaryGradient = 'linear-gradient(135deg, #6366F1 0%, #A855F7 100%)';
  static const warmGradient = 'linear-gradient(135deg, #F59E0B 0%, #EC4899 100%)';
  static const successGradient = 'linear-gradient(135deg, #22C55E 0%, #3B82F6 100%)';
}
```

### タイポグラフィシステム

```dart
class TempoTextStyles {
  static const fontFamily = 'Inter'; // システムフォントから変更
  static const japaneseFallback = 'Noto Sans JP';
  
  // Display - 大きな見出し
  static const display1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 48,
    fontWeight: FontWeight.w800,
    height: 1.1,
    letterSpacing: -0.02,
  );
  
  static const display2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.01,
  );
  
  // Headlines - 見出し
  static const headline1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );
  
  static const headline2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
  
  static const headline3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  
  // Body - 本文
  static const bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  
  static const bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  
  static const bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  
  // Special Purpose
  static const buttonLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
  
  static const buttonMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );
  
  static const caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.4,
  );
  
  static const overline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: 1.5,
    textTransform: TextTransform.uppercase,
  );
}
```

### 空間設計システム

```dart
class TempoSpacing {
  // 基本スケール（8pxベース）
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
  
  // コンポーネント固有
  static const double cardPadding = 20.0;
  static const double screenPadding = 24.0;
  static const double buttonHeight = 52.0;
  static const double inputHeight = 60.0;
  static const double avatarSmall = 40.0;
  static const double avatarMedium = 56.0;
  static const double avatarLarge = 80.0;
  static const double avatarXLarge = 96.0;
  
  // ブレークポイント
  static const double maxContentWidth = 480.0;
}
```

---

## 🌟 革新的コンポーネント設計

### 1. 呼吸するアバター
```dart
class BreathingAvatar extends StatefulWidget {
  final String imageUrl;
  final double size;
  final bool isOnline;
  
  @override
  _BreathingAvatarState createState() => _BreathingAvatarState();
}

class _BreathingAvatarState extends State<BreathingAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  TempoColors.primary,
                  TempoColors.secondary,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: TempoColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.size / 2),
              child: widget.imageUrl.isNotEmpty
                  ? CachedNetworkImage(imageUrl: widget.imageUrl)
                  : _buildDefaultAvatar(),
            ),
          ),
        );
      },
    );
  }
}
```

### 2. 時間の美しい可視化
```dart
class TimeIndicator extends StatelessWidget {
  final Duration remaining;
  final Duration total;
  final bool isWarning;
  
  @override
  Widget build(BuildContext context) {
    final progress = remaining.inSeconds / total.inSeconds;
    final circumference = 2 * math.pi * 20;
    
    return Container(
      width: 48,
      height: 48,
      child: Stack(
        children: [
          // 背景円
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: TempoColors.surface.withOpacity(0.1),
            ),
          ),
          
          // プログレス円
          CustomPaint(
            size: Size(48, 48),
            painter: CircularProgressPainter(
              progress: progress,
              color: isWarning ? TempoColors.warning : TempoColors.primary,
              strokeWidth: 3.0,
            ),
          ),
          
          // 中央テキスト
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${remaining.inHours}',
                  style: TempoTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isWarning 
                        ? TempoColors.warning 
                        : TempoColors.primary,
                  ),
                ),
                Text(
                  'h',
                  style: TempoTextStyles.overline.copyWith(
                    fontSize: 8,
                    color: TempoColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### 3. 洗練されたボタンシステム
```dart
class TempoButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final TempoButtonVariant variant;
  final TempoButtonSize size;
  final IconData? leadingIcon;
  final bool isLoading;
  
  @override
  _TempoButtonState createState() => _TempoButtonState();
}

class _TempoButtonState extends State<TempoButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            height: _getHeight(),
            decoration: BoxDecoration(
              gradient: _getGradient(),
              borderRadius: BorderRadius.circular(_getBorderRadius()),
              boxShadow: _getShadow(),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onPressed,
                onTapDown: (_) => _controller.forward(),
                onTapUp: (_) => _controller.reverse(),
                onTapCancel: () => _controller.reverse(),
                borderRadius: BorderRadius.circular(_getBorderRadius()),
                child: _buildContent(),
              ),
            ),
          ),
        );
      },
    );
  }
}
```

---

## 📱 新規ユーザー体験設計

### オンボーディングフロー
```dart
class OnboardingFlow extends StatefulWidget {
  @override
  _OnboardingFlowState createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 背景グラデーション
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  TempoColors.primary,
                  TempoColors.secondary,
                ],
              ),
            ),
          ),
          
          // メインコンテンツ
          PageView(
            controller: _pageController,
            onPageChanged: (page) => setState(() => _currentPage = page),
            children: [
              _buildWelcomePage(),
              _buildConceptPage(),
              _buildHowItWorksPage(),
              _buildPermissionsPage(),
            ],
          ),
          
          // ページインジケーター
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: _buildPageIndicator(),
          ),
          
          // ナビゲーションボタン
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: _buildNavigationButtons(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWelcomePage() {
    return Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ロゴアニメーション
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(seconds: 2),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        Colors.white.withOpacity(0.8),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'T',
                      style: TempoTextStyles.display1.copyWith(
                        color: TempoColors.primary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          SizedBox(height: 48),
          
          Text(
            'Tempo',
            style: TempoTextStyles.display2.copyWith(
              color: Colors.white,
            ),
          ),
          
          SizedBox(height: 16),
          
          Text(
            '今この瞬間を、誰かと',
            style: TempoTextStyles.bodyLarge.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          
          SizedBox(height: 64),
          
          _buildFeatureHighlight(
            '📱',
            '数字のないSNS',
            'フォロワー数もいいね数も表示しません',
          ),
          
          SizedBox(height: 24),
          
          _buildFeatureHighlight(
            '⏰',
            '24時間限定の出会い',
            '一期一会の特別な繋がりを大切に',
          ),
          
          SizedBox(height: 24),
          
          _buildFeatureHighlight(
            '💫',
            '今この瞬間',
            '同じ気分、同じ活動の人とマッチング',
          ),
        ],
      ),
    );
  }
}
```

### 3分で価値実感フロー
```
0:00 - アプリ起動
0:10 - 「ようこそ！」画面
0:30 - 簡単ステータス設定
1:00 - 「同じテンポの人が見つかりました！」
1:30 - マッチング成功演出
2:00 - 初回メッセージ交換
2:30 - 応援スタンプ体験
3:00 - 「友達を招待して特典ゲット！」
```

---

## 🎨 バイラル機能のUI設計

### テンポカード作成
```dart
class TempoCardCreator extends StatefulWidget {
  final TempoStatus status;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 400,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            TempoColors.primary,
            TempoColors.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: TempoColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tempoロゴ
            Text(
              'Tempo',
              style: TempoTextStyles.headline2.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w300,
              ),
            ),
            
            SizedBox(height: 24),
            
            // 大きなエモジ
            Text(
              status.mood,
              style: TextStyle(fontSize: 80),
            ),
            
            SizedBox(height: 24),
            
            // ステータステキスト
            Text(
              status.activity,
              style: TempoTextStyles.headline3.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            if (status.message.isNotEmpty) ...[
              SizedBox(height: 16),
              Text(
                '"${status.message}"',
                style: TempoTextStyles.bodyMedium.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            SizedBox(height: 32),
            
            // 時刻
            Text(
              DateFormat('HH:mm').format(DateTime.now()),
              style: TempoTextStyles.bodySmall.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            
            Spacer(),
            
            // CTA
            Text(
              '今この瞬間を、誰かと',
              style: TempoTextStyles.bodySmall.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 思い出カード自動生成
```dart
class MemoryCard extends StatelessWidget {
  final TempoConnection connection;
  final List<String> highlights;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 500,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: Offset(0, 15),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            // ヘッダー
            Row(
              children: [
                BreathingAvatar(
                  imageUrl: connection.otherUser.imageUrl,
                  size: 48,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${connection.otherUser.name}さんとの24時間',
                        style: TempoTextStyles.headline3,
                      ),
                      Text(
                        '${DateFormat('yyyy/MM/dd').format(connection.startedAt)}',
                        style: TempoTextStyles.bodySmall.copyWith(
                          color: TempoColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 32),
            
            // ハイライト
            ...highlights.map((highlight) => _buildHighlight(highlight)),
            
            Spacer(),
            
            // フッター
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    TempoColors.primary.withOpacity(0.1),
                    TempoColors.secondary.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('✨', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 8),
                  Text(
                    'Tempoで素敵な出会いを',
                    style: TempoTextStyles.bodySmall.copyWith(
                      color: TempoColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 📐 レスポンシブ設計

### 画面サイズ対応
```dart
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth >= 1200 && desktop != null) {
      return desktop!;
    } else if (screenWidth >= 768 && tablet != null) {
      return tablet!;
    } else {
      return mobile;
    }
  }
}

// 使用例
ResponsiveLayout(
  mobile: MobileHomeLayout(),
  tablet: TabletHomeLayout(),
)
```

### 安全領域対応
```dart
class SafeAreaBuilder extends StatelessWidget {
  final Widget child;
  final bool top;
  final bool bottom;
  
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final safePadding = mediaQuery.padding;
    
    return Padding(
      padding: EdgeInsets.only(
        top: top ? safePadding.top : 0,
        bottom: bottom ? safePadding.bottom : 0,
      ),
      child: child,
    );
  }
}
```

---

## 🌙 ダークモード完全対応

### テーマ切り替えシステム
```dart
class ThemeController extends StateNotifier<ThemeMode> {
  ThemeController() : super(ThemeMode.system);
  
  void setThemeMode(ThemeMode mode) {
    state = mode;
    // SharedPreferencesに保存
    _saveThemeMode(mode);
  }
  
  void toggleTheme() {
    state = state == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    _saveThemeMode(state);
  }
}

final themeControllerProvider = 
    StateNotifierProvider<ThemeController, ThemeMode>((ref) {
  return ThemeController();
});
```

### ダークテーマ定義
```dart
class TempoDarkTheme {
  static final ThemeData theme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: TempoColors.primary,
    scaffoldBackgroundColor: TempoColors.background,
    cardColor: TempoColors.surface,
    dividerColor: TempoColors.textTertiary.withOpacity(0.1),
    
    // AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: TempoColors.surface,
      foregroundColor: TempoColors.textPrimary,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    
    // BottomNavigationBar
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: TempoColors.surface,
      selectedItemColor: TempoColors.primary,
      unselectedItemColor: TempoColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    
    // TextTheme
    textTheme: TextTheme(
      displayLarge: TempoTextStyles.display1.copyWith(
        color: TempoColors.textPrimary,
      ),
      // ... 他のテキストスタイル
    ),
  );
}
```

---

## ♿ アクセシビリティ強化

### セマンティクス対応
```dart
class AccessibleButton extends StatelessWidget {
  final String text;
  final String semanticLabel;
  final VoidCallback onPressed;
  
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: onPressed != null,
      child: TempoButton(
        text: text,
        onPressed: onPressed,
      ),
    );
  }
}
```

### コントラスト比チェック
```dart
class ContrastChecker {
  static bool meetsWCAGAA(Color foreground, Color background) {
    final ratio = calculateContrastRatio(foreground, background);
    return ratio >= 4.5;
  }
  
  static bool meetsWCAGAAA(Color foreground, Color background) {
    final ratio = calculateContrastRatio(foreground, background);
    return ratio >= 7.0;
  }
  
  static double calculateContrastRatio(Color color1, Color color2) {
    // WCAG contrast ratio calculation
    // Implementation details...
  }
}
```

---

## 🎬 アニメーション詳細設計

### マイクロインタラクション
```dart
class MicroAnimations {
  // マッチング成功時の演出
  static Widget matchSuccessAnimation({
    required Widget child,
    required VoidCallback onComplete,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 1500),
      curve: Curves.elasticOut,
      onEnd: onComplete,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
  
  // スタンプ送信時のバウンス
  static Widget stampBounceAnimation(Widget child) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500),
      curve: Curves.bounceOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.5 + (0.5 * value),
          child: Transform.rotate(
            angle: (1 - value) * 0.1,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
```

### ページ遷移アニメーション
```dart
class TempoPageTransitions {
  static Route<T> slideFromRight<T extends Object?>(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;
        
        var tween = Tween(begin: begin, end: end)
            .chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
      transitionDuration: Duration(milliseconds: 300),
    );
  }
  
  static Route<T> fadeScale<T extends Object?>(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            ),
            child: child,
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 400),
    );
  }
}
```

---

## 🎯 パフォーマンス最適化

### Widget最適化
```dart
class OptimizedListView extends StatelessWidget {
  final List<Widget> children;
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: children.length,
      cacheExtent: 500, // プリキャッシュサイズ
      itemBuilder: (context, index) {
        return RepaintBoundary(
          child: children[index],
        );
      },
    );
  }
}
```

### 画像最適化
```dart
class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: TempoColors.surface,
        highlightColor: TempoColors.textTertiary.withOpacity(0.1),
        child: Container(
          width: width,
          height: height,
          color: TempoColors.surface,
        ),
      ),
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              TempoColors.primary.withOpacity(0.1),
              TempoColors.secondary.withOpacity(0.1),
            ],
          ),
        ),
        child: Icon(
          Icons.person,
          color: TempoColors.textSecondary,
          size: width * 0.4,
        ),
      ),
      memCacheWidth: (width * MediaQuery.of(context).devicePixelRatio).round(),
      memCacheHeight: (height * MediaQuery.of(context).devicePixelRatio).round(),
    );
  }
}
```

---

**このUI/UX設計書は、美しさと機能性、そしてユーザー体験の向上を追求し続けます。**

**作成日**: 2025/01/XX  
**最終更新**: 2025/01/XX  
**バージョン**: 2.0.0