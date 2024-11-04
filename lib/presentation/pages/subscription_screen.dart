// subscription_model.dart
import 'dart:async';

import 'package:app/core/utils/debug_print.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/providers/provider/firebase/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';

class Subscription {
  final String id;
  final String type;
  final DateTime expiryDate;
  final bool isActive;
  final String? productId;
  final String? transactionId;

  Subscription({
    required this.id,
    required this.type,
    required this.expiryDate,
    required this.isActive,
    this.productId,
    this.transactionId,
  });

  factory Subscription.fromFirestore(Map<String, dynamic> data) {
    return Subscription(
      id: data['id'],
      type: data['type'],
      expiryDate: (data['expiryDate'] as Timestamp).toDate(),
      isActive: data['isActive'],
      productId: data['productId'],
      transactionId: data['transactionId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'expiryDate': Timestamp.fromDate(expiryDate),
      'isActive': isActive,
      'productId': productId,
      'transactionId': transactionId,
    };
  }
}

// purchase_service.dart
class PurchaseService {
  static const String _kBasicSubscription = 'basic_monthly';
  static const String _kPremiumSubscription = 'new_monthly';

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final StreamController<List<ProductDetails>> _productsController =
      StreamController<List<ProductDetails>>.broadcast();

  Stream<List<ProductDetails>> get products => _productsController.stream;
  List<ProductDetails> _products = [];

  Future<void> initialize() async {
    final available = await _inAppPurchase.isAvailable();

    if (!available) {
      _productsController.add([]);
      return;
    }

    final Set<String> ids = {_kBasicSubscription, _kPremiumSubscription};
    final ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(ids);

    _products = response.productDetails;
    _productsController.add(_products);
  }

  Future<void> buySubscription(ProductDetails product) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Stream<List<PurchaseDetails>> get purchaseUpdated =>
      _inAppPurchase.purchaseStream;

  void dispose() {
    _productsController.close();
  }
}

// subscription_service.dart
class SubscriptionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String uid;

  SubscriptionService({required this.uid});

  Future<Subscription?> getCurrentSubscription() async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('subscriptions')
          .where('isActive', isEqualTo: true)
          .get();

      if (doc.docs.isEmpty) return null;

      return Subscription.fromFirestore(doc.docs.first.data());
    } catch (e) {
      DebugPrint('Error getting subscription: $e');
      return null;
    }
  }

  Stream<Subscription?> subscriptionStream() {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('subscriptions')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return Subscription.fromFirestore(snapshot.docs.first.data());
    });
  }

  Future<void> createSubscription({
    required String type,
    required DateTime expiryDate,
    String? productId,
    String? transactionId,
  }) async {
    try {
      final subscription = Subscription(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: type,
        expiryDate: expiryDate,
        isActive: true,
        productId: productId,
        transactionId: transactionId,
      );

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('subscriptions')
          .doc(subscription.id)
          .set(subscription.toMap());
    } catch (e) {
      DebugPrint('Error creating subscription: $e');
      rethrow;
    }
  }

  Future<void> updateSubscription(Subscription subscription) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('subscriptions')
          .doc(subscription.id)
          .update(subscription.toMap());
    } catch (e) {
      DebugPrint('Error updating subscription: $e');
      rethrow;
    }
  }

  Future<void> deactivateSubscription(Subscription subscription) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('subscriptions')
          .doc(subscription.id)
          .update({'isActive': false});
    } catch (e) {
      DebugPrint('Error deactivating subscription: $e');
      rethrow;
    }
  }

  Future<void> handlePurchase(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.status == PurchaseStatus.purchased ||
        purchaseDetails.status == PurchaseStatus.restored) {
      final String type =
          purchaseDetails.productID.contains('basic') ? 'basic' : 'premium';

      // 1年間の購読期間を設定
      final expiryDate = DateTime.now().add(const Duration(days: 365));

      await createSubscription(
        type: type,
        expiryDate: expiryDate,
        productId: purchaseDetails.productID,
        transactionId: purchaseDetails.purchaseID,
      );
    }
  }
}

// subscription_screen.dart
/*class SubscriptionScreen extends StatefulWidget {
  final String uid;

  SubscriptionScreen({required this.uid});

  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final PurchaseService _purchaseService = PurchaseService();
  late SubscriptionService _subscriptionService;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  @override
  void initState() {
    super.initState();
    _subscriptionService = SubscriptionService(uid: widget.uid);
    _initialize();
  }

  Future<void> _initialize() async {
    await _purchaseService.initialize();
    _purchaseSubscription = _purchaseService.purchaseUpdated.listen(
      (purchases) async {
        for (var purchase in purchases) {
          if (purchase.status == PurchaseStatus.pending) {
            _showPendingUI();
          } else if (purchase.status == PurchaseStatus.error) {
            _handleError(purchase.error!);
          } else if (purchase.status == PurchaseStatus.purchased ||
              purchase.status == PurchaseStatus.restored) {
            await _subscriptionService.handlePurchase(purchase);
          }
          if (purchase.pendingCompletePurchase) {
            await InAppPurchase.instance.completePurchase(purchase);
          }
        }
      },
    );
  }

  void _showPendingUI() {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('処理中です...')));
  }

  void _handleError(IAPError error) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('エラーが発生しました: ${error.message}')));
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    _purchaseService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('サブスクリプション情報'),
      ),
      body: StreamBuilder<Subscription?>(
        stream: _subscriptionService.subscriptionStream(),
        builder: (context, subscriptionSnapshot) {
          return StreamBuilder<List<ProductDetails>>(
            stream: _purchaseService.products,
            builder: (context, productsSnapshot) {
              if (subscriptionSnapshot.hasError) {
                return Text(
                    "subscriptionSnapshot error : ${subscriptionSnapshot.error}");
              }
              if (productsSnapshot.hasError) {
                return Text(
                    "productsSnapshot error : ${productsSnapshot.error}");
              }

              if (!subscriptionSnapshot.hasData && !productsSnapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              final subscription = subscriptionSnapshot.data;
              final products = productsSnapshot.data ?? [];

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (subscription != null) ...[
                      _buildCurrentSubscription(subscription),
                      const SizedBox(height: 24),
                      const Text(
                        '他のプランを選択する',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ] else
                      const Text(
                        '利用可能なプラン',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(height: 16),
                    ...products.map((product) => _buildProductCard(product)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCurrentSubscription(Subscription subscription) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '現在のプラン',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${subscription.type == "basic" ? "ベーシック" : "プレミアム"}プラン',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '有効期限: ${DateFormat('yyyy/MM/dd').format(subscription.expiryDate)}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(ProductDetails product) {
    return Container(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.title,
          ),
          Text(product.description),
          const SizedBox(height: 4),
          Text(product.price),
          Material(
            color: ThemeColor.stroke,
            child: InkWell(
              onTap: () {
                _purchaseService.buySubscription(product);
              },
              child: Container(
                child: Text("購入"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
 */
final purchaseServiceProvider =
    Provider((ref) => PurchaseService()..initialize());
final subscriptionServiceProvider = Provider(
  (ref) => SubscriptionService(uid: ref.read(authProvider).currentUser!.uid),
);

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchaseService = ref.watch(purchaseServiceProvider);
    final subscriptionService = ref.watch(subscriptionServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('サブスクリプション情報'),
      ),
      body: StreamBuilder<Subscription?>(
        stream: subscriptionService.subscriptionStream(),
        builder: (context, subscriptionSnapshot) {
          return StreamBuilder<List<ProductDetails>>(
            stream: purchaseService.products,
            builder: (context, productsSnapshot) {
              if (subscriptionSnapshot.hasError) {
                return Text(
                    "subscriptionSnapshot error : ${subscriptionSnapshot.error}");
              }
              if (productsSnapshot.hasError) {
                return Text(
                    "productsSnapshot error : ${productsSnapshot.error}");
              }
              if (!subscriptionSnapshot.hasData && !productsSnapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              final subscription = subscriptionSnapshot.data;
              final products = productsSnapshot.data ?? [];

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (subscription != null) ...[
                      _buildCurrentSubscription(subscription),
                      const SizedBox(height: 24),
                      const Text(
                        '他のプランを選択する',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ] else
                      const Text(
                        '利用可能なプラン',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(height: 16),
                    ...products.map((product) => _buildProductCard(
                        context, ref, product, purchaseService)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCurrentSubscription(Subscription subscription) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '現在のプラン',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${subscription.type == "basic" ? "ベーシック" : "プレミアム"}プラン',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '有効期限: ${DateFormat('yyyy/MM/dd').format(subscription.expiryDate)}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, WidgetRef ref,
      ProductDetails product, PurchaseService purchaseService) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final textStyle = ThemeTextStyle(themeSize: themeSize);
    String price;
    if (product.id == PurchaseService._kBasicSubscription) {
      price = '¥${480.toStringAsFixed(0)}';
    } else if (product.id == PurchaseService._kPremiumSubscription) {
      price = '¥${360.toStringAsFixed(0)}';
    } else {
      price = product.price;
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ThemeColor.stroke,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.title,
            style: textStyle.w600(fontSize: 18),
          ),
          Text(
            product.description,
            style: textStyle.w600(
              fontSize: 16,
              color: ThemeColor.subText,
            ),
          ),
          const SizedBox(height: 4),
          Text(price),
          const Gap(24),
          Center(
            child: Material(
              color: ThemeColor.stroke,
              child: InkWell(
                onTap: () {
                  purchaseService.buySubscription(product);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: ThemeColor.subText,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Center(
                    child: Text(
                      "ProPlanを入手する",
                      style: textStyle.w600(
                        fontSize: 16,
                        color: ThemeColor.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
