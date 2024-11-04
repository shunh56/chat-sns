// Native広告のステートを管理するプロバイダー
import 'package:app/core/utils/debug_print.dart';
import 'package:app/presentation/components/admob/ad_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

final bannerAdProvider =
    StateNotifierProvider<BannerAdNotifier, BannerAd?>((ref) {
  return BannerAdNotifier();
});

class BannerAdNotifier extends StateNotifier<BannerAd?> {
  BannerAdNotifier() : super(null) {
    loadAd();
  }

  void loadAd() {
    BannerAd(
      adUnitId: AdHelperTest.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          state = ad as BannerAd;
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          DebugPrint('Native ad failed to load: $error');
        },
      ),
    ).load();
  }

  @override
  void dispose() {
    state?.dispose();
    super.dispose();
  }
}

class BannerAdWidget extends ConsumerWidget {
  const BannerAdWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannerAd = ref.watch(bannerAdProvider);

    return bannerAd == null
        ? const SizedBox.shrink()
        : Container(
            height: 72.0,
            alignment: Alignment.center,
            child: AdWidget(ad: bannerAd),
          );
  }
}
