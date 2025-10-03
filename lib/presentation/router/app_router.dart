import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/datasource/firebase/firebase_auth.dart';
import '../../data/datasource/firebase/firebase_remote_config.dart';
import '../../domain/entity/user.dart';
import '../pages/account_status_screen/banned_screen.dart';
import '../pages/account_status_screen/deleted_screen.dart';
import '../pages/account_status_screen/freezed_screen.dart';
import '../pages/main_page/error_page.dart';
import '../pages/main_page/loading_page.dart';
import '../pages/main_page/main_page.dart';
import '../pages/main_page/maintenance_screen.dart';
import '../pages/main_page/welcome_page.dart';
import '../pages/onboarding/onboarding_screen.dart';
import '../pages/onboarding/shared_preferences_provider.dart';
import '../pages/onboaring_account/onboarding_screen.dart';
import '../pages/version/update_notifier.dart';
import '../providers/users/my_user_account_notifier.dart';

/// アプリケーションのルーティングを管理するプロバイダー
final appRouterProvider = Provider<GoRouter>((ref) {
  return AppRouter(ref).router;
});

/// アプリケーションのルーティング設定
class AppRouter {
  final Ref _ref;

  AppRouter(this._ref);

  /// ルーター設定
  late final router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: _createRefreshListenable(),
    routes: _routes,
    redirect: _redirect,
    errorBuilder: (context, state) => ErrorPage(
      e: state.error ?? Exception('Navigation error'),
      s: StackTrace.current,
    ),
  );

  /// ルート定義
  List<RouteBase> get _routes => [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const UpdateNotifier(
        child: _InitialLoadingScreen(),
      ),
    ),
    GoRoute(
      path: '/maintenance',
      name: 'maintenance',
      builder: (context, state) => const MaintenanceScreen(),
    ),
    GoRoute(
      path: '/welcome',
      name: 'welcome',
      builder: (context, state) => const WelcomePage(),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/onboarding-flow',
      name: 'onboarding-flow',
      builder: (context, state) => const OnboardingFlowScreen(),
    ),
    GoRoute(
      path: '/banned',
      name: 'banned',
      builder: (context, state) => const BannedAccountScreen(),
    ),
    GoRoute(
      path: '/freezed',
      name: 'freezed',
      builder: (context, state) => const FreezedAccountScreen(),
    ),
    GoRoute(
      path: '/deleted',
      name: 'deleted',
      builder: (context, state) => const DeletedAccountScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const MainPageWrapper(),
    ),
  ];

  /// リダイレクト処理
  Future<String?> _redirect(BuildContext context, GoRouterState state) async {
    // メンテナンスチェック
    final remoteConfig = await _ref.read(remoteConfigProvider.future);
    if (remoteConfig.getBool('isUnderMaintenance')) {
      return '/maintenance';
    }

    // 認証状態チェック
    final authStream = _ref.read(authChangeProvider);
    final user = await authStream.future;

    if (user == null) {
      // 未認証の場合
      if (state.matchedLocation != '/welcome') {
        return '/welcome';
      }
      return null;
    }

    // 認証済みの場合、アカウント情報を確認
    final accountAsync = await _ref.read(myAccountNotifierProvider.future);

    // ユーザー名未設定の場合
    if (accountAsync.username == "null") {
      if (state.matchedLocation != '/onboarding') {
        return '/onboarding';
      }
      return null;
    }

    // アカウントステータスの確認
    switch (accountAsync.accountStatus) {
      case AccountStatus.banned:
        if (state.matchedLocation != '/banned') {
          return '/banned';
        }
        break;
      case AccountStatus.freezed:
        if (state.matchedLocation != '/freezed') {
          return '/freezed';
        }
        break;
      case AccountStatus.deleted:
        if (state.matchedLocation != '/deleted') {
          return '/deleted';
        }
        break;
      default:
        // オンボーディング完了チェック
        final onboardingState = await _ref.read(initialOnboardingStateProvider.future);
        if (!onboardingState.isCompleted) {
          if (state.matchedLocation != '/onboarding-flow') {
            return '/onboarding-flow';
          }
          return null;
        }

        // すべての条件をクリアしたらホームへ
        if (state.matchedLocation == '/splash' ||
            state.matchedLocation == '/welcome' ||
            state.matchedLocation == '/onboarding' ||
            state.matchedLocation == '/onboarding-flow') {
          return '/home';
        }
    }

    return null;
  }

  /// リフレッシュ用のListenableを作成
  Listenable _createRefreshListenable() {
    // 複数の状態変化を監視するためのカスタムListenable
    return _MultiProviderRefreshListenable(_ref, [
      remoteConfigProvider,
      authChangeProvider,
      myAccountNotifierProvider,
      initialOnboardingStateProvider,
    ]);
  }
}

/// 初期ローディング画面
class _InitialLoadingScreen extends ConsumerWidget {
  const _InitialLoadingScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 各種プロバイダーを監視して自動的にリダイレクト
    ref.watch(remoteConfigProvider);
    ref.watch(authChangeProvider);
    ref.watch(myAccountNotifierProvider);
    ref.watch(initialOnboardingStateProvider);

    return const LoadingPage();
  }
}

/// 複数のプロバイダーを監視するListenable
class _MultiProviderRefreshListenable extends ChangeNotifier {
  final Ref _ref;
  final List<ProviderBase> _providers;
  final List<ProviderSubscription> _subscriptions = [];

  _MultiProviderRefreshListenable(this._ref, this._providers) {
    _initialize();
  }

  void _initialize() {
    for (final provider in _providers) {
      final subscription = _ref.listen(
        provider,
        (previous, next) => notifyListeners(),
      );
      _subscriptions.add(subscription);
    }
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.close();
    }
    super.dispose();
  }
}