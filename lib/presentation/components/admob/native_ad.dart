
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/admob/ad_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// Native広告のステートを管理するプロバイダー
final nativeAdProvider =
    StateNotifierProvider.family<NativeAdNotifier, NativeAd?, String>(
        (ref, key) {
  return NativeAdNotifier();
});

class NativeAdNotifier extends StateNotifier<NativeAd?> {
  NativeAdNotifier() : super(null) {
    loadAd();
  }

  void loadAd() {
    NativeAd(
      adUnitId: AdHelperTest.nativeAdUnitId,
      //factoryId: 'listTile',
      nativeTemplateStyle: NativeTemplateStyle(
        // Required: Choose a template.
        templateType: TemplateType.medium,
        // Optional: Customize the ad's style.
        mainBackgroundColor: ThemeColor.accent,
        cornerRadius: 12.0,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: Colors.pink,
          style: NativeTemplateFontStyle.bold,
          size: 14.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: Colors.white.withOpacity(0.1),
          style: NativeTemplateFontStyle.normal,
          size: 12.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.green,
          backgroundColor: Colors.white.withOpacity(0.5),
          style: NativeTemplateFontStyle.bold,
          size: 20.0,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: Colors.orange,
          style: NativeTemplateFontStyle.bold,
          size: 6.0,
        ),
      ),
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          state = ad as NativeAd;
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('Native ad failed to load: $error');
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

class NativeAdWidget extends ConsumerWidget {
  const NativeAdWidget({super.key, required this.id});
  final String id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nativeAd = ref.watch(nativeAdProvider(id));
    final themeSize = ref.watch(themeSizeProvider(context));
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      height: 372,
      width: themeSize.screenWidth,
      decoration: BoxDecoration(
        color: ThemeColor.accent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ThemeColor.stroke,
          width: 0.4,
        ),
      ),
      child: nativeAd == null
          ? const SizedBox()
          : Container(
              padding: const EdgeInsets.only(
                top: 16,
                left: 24,
                right: 24,
                bottom: 8,
              ),
              child: AdWidget(
                ad: nativeAd,
              ),
            ),
    );
  }
}
