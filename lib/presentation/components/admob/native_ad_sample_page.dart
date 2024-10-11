import 'package:app/presentation/components/admob/ad_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class Destination {
  static final List<Destination> samples = [
    Destination(
      name: 'Aspen, United States',
      duration: '1 stop · 6h 15m',
      asset: 'crane/destinations/fly_0.jpg',
    ),
    Destination(
      name: 'Big Sur, United States',
      duration: 'Nonstop · 13h 30m',
      asset: 'crane/destinations/fly_1.jpg',
    ),
    Destination(
      name: 'Khumbu Valley, Nepal',
      duration: 'Nonstop · 5h 16m',
      asset: 'crane/destinations/fly_2.jpg',
    ),
    Destination(
      name: 'Machu Picchu, Peru',
      duration: '2 stops · 19h 40m',
      asset: 'crane/destinations/fly_3.jpg',
    ),
    Destination(
      name: 'Malé, Maldives',
      duration: 'Nonstop · 8h 24m',
      asset: 'crane/destinations/fly_4.jpg',
    ),
    Destination(
      name: 'Vitznau, Switzerland',
      duration: '1 stop · 14h 12m',
      asset: 'crane/destinations/fly_5.jpg',
    ),
    Destination(
      name: 'Mexico City, Mexico',
      duration: 'Nonstop · 5h 24m',
      asset: 'crane/destinations/fly_6.jpg',
    ),
    Destination(
      name: 'Mount Rushmore, United States',
      duration: '1 stop · 5h 43m',
      asset: 'crane/destinations/fly_7.jpg',
    ),
    Destination(
      name: 'Singapore',
      duration: 'Nonstop · 8h 25m',
      asset: 'crane/destinations/fly_8.jpg',
    ),
    Destination(
      name: 'Havana, Cuba',
      duration: '1 stop · 15h 52m',
      asset: 'crane/destinations/fly_9.jpg',
    ),
    Destination(
      name: 'Cairo, Egypt',
      duration: 'Nonstop · 5h 57m',
      asset: 'crane/destinations/fly_10.jpg',
    ),
    Destination(
      name: 'Lisbon, Portugal',
      duration: '1 stop · 13h 24m',
      asset: 'crane/destinations/fly_11.jpg',
    ),
  ];

  final String name;

  final String duration;

  final String asset;

  Destination({
    required this.name,
    required this.duration,
    required this.asset,
  });
}

class NativeInlinePage extends StatefulWidget {
  const NativeInlinePage({
    super.key,
  });

  @override
  State createState() => _NativeInlinePageState();
}

class _NativeInlinePageState extends State<NativeInlinePage> {
  // TODO: Add _kAdIndex
  static const _kAdIndex = 4;

  // TODO: Add a native ad instance
  NativeAd? _ad;

  int _getDestinationItemIndex(int rawIndex) {
    if (rawIndex >= _kAdIndex && _ad != null) {
      return rawIndex - 1;
    }
    return rawIndex;
  }

  @override
  void initState() {
    super.initState();

    try {
      _ad = NativeAd(
        adUnitId: AdHelperTest.nativeAdUnitId,
        factoryId: 'listTile',
        request: const AdRequest(),
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            setState(() {
              _ad = ad as NativeAd;
            });
          },
          onAdFailedToLoad: (ad, error) {
            // Releases an ad resource when it fails to load
            ad.dispose();
            print(
                'Ad load failed (code=${error.code} message=${error.message})');
          },
        ),
      );

      _ad?.load();
    } catch (e) {
      debugPrint("ERROR : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = Destination.samples;
    return Scaffold(
      appBar: AppBar(
        title: const Text('AdMob Native Inline Ad'),
      ),
      body: ListView.builder(
        // TODO: Adjust itemCount based on the ad load state
        itemCount: entries.length,
        itemBuilder: (context, index) {
          // TODO: Render a native ad

          // TODO: Get adjusted item index from _getDestinationItemIndex()
          final item = entries[index];

          if (_ad != null && index == _kAdIndex) {
            return ListTile(
              leading: const CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey,
              ),
              title: Text(item.name),
              subtitle: Text(item.duration),
              onTap: () {
                debugPrint('Clicked ${item.name}');
              },
            );
            return Container(
              height: 72.0,
              alignment: Alignment.center,
              child: AdWidget(ad: _ad!),
            );
          } else {
            // TODO: Get adjusted item index from _getDestinationItemIndex()
            final item = entries[_getDestinationItemIndex(index)];

            return ListTile(
              leading: const CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white,
              ),
              title: Text(item.name),
              subtitle: Text(item.duration),
              onTap: () {
                debugPrint('Clicked ${item.name}');
              },
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    // TODO: Dispose a NativeAd object

    super.dispose();
  }

// TODO: Add _getDestinationItemIndex()
}
