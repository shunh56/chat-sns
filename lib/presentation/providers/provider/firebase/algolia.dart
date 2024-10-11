import 'package:algolia/algolia.dart';

// Package imports:

import 'package:flutter_riverpod/flutter_riverpod.dart';

final algoliaProvider = Provider(
  (ref) => const Algolia.init(
    applicationId: 'LYXA0CBNFA',
    apiKey: '989c0fe051a91ee717e4e83c8f31b7cb',
  ),
);
