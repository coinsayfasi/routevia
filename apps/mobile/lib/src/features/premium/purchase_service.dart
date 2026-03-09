import 'dart:async';
import 'dart:io';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/billing_catalog.dart';

class PurchaseCatalogState {
  const PurchaseCatalogState({
    required this.storeAvailable,
    required this.products,
    required this.notFoundIds,
  });

  final bool storeAvailable;
  final List<ProductDetails> products;
  final List<String> notFoundIds;
}

class PurchaseService {
  PurchaseService({InAppPurchase? iap}) : _iap = iap ?? InAppPurchase.instance;

  final InAppPurchase _iap;

  Stream<List<PurchaseDetails>> get purchaseStream => _iap.purchaseStream;

  Future<PurchaseCatalogState> loadCatalog() async {
    final available = await _iap.isAvailable();
    if (!available) {
      return const PurchaseCatalogState(
        storeAvailable: false,
        products: [],
        notFoundIds: [],
      );
    }

    final response = await _iap.queryProductDetails(BillingCatalog.storeProductIds);
    if (response.error != null) {
      throw Exception(response.error!.message);
    }

    final products = [...response.productDetails]
      ..sort((a, b) => a.rawPrice.compareTo(b.rawPrice));

    return PurchaseCatalogState(
      storeAvailable: true,
      products: products,
      notFoundIds: response.notFoundIDs,
    );
  }

  Future<void> buy(ProductDetails product) async {
    final purchaseParam = PurchaseParam(productDetails: product);
    final ok = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    if (!ok) {
      throw Exception('Store satin alma akisi baslatilamadi.');
    }
  }

  Future<void> restore() => _iap.restorePurchases();

  Future<void> complete(PurchaseDetails purchase) async {
    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
    }
  }

  static Future<Map<String, dynamic>> verifyPurchase(
    SupabaseClient client,
    PurchaseDetails purchase,
  ) async {
    final token = client.auth.currentSession?.accessToken;
    if (token == null || token.isEmpty) {
      throw Exception('Oturum bulunamadi. Lutfen tekrar giris yap.');
    }
    final platform = Platform.isIOS ? 'ios' : 'android';
    final purchaseToken = purchase.verificationData.serverVerificationData;
    final result = await client.functions.invoke(
      'verify_purchase',
      headers: {'Authorization': 'Bearer $token'},
      body: {
        'platform': platform,
        'purchase_token': purchaseToken,
        'product_id': purchase.productID,
      },
    );
    return Map<String, dynamic>.from(result.data as Map);
  }
}
