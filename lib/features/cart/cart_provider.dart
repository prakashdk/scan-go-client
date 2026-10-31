// lib/features/cart/cart_provider.dart

import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_service.dart';
import '../../core/models/models.dart';

class CartProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  CartResponse? _cart;
  bool _loading = false;
  bool _scanning = false;
  String? _error;
  String? _lastScanned;

  CartResponse? get cart => _cart;
  bool get loading => _loading;
  bool get scanning => _scanning;
  String? get error => _error;
  String? get lastScanned => _lastScanned;

  Future<void> loadCart(String cartId) async {
    _setLoading(true);
    try {
      _cart = await _api.getCart(cartId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addItem(String cartId, String barcode) async {
    _scanning = true;
    _lastScanned = barcode;
    _error = null;
    notifyListeners();
    try {
      _cart = await _api.addItem(cartId, barcode);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      notifyListeners();
      return false;
    } finally {
      _scanning = false;
      notifyListeners();
    }
  }

  Future<bool> decreaseItem(String cartId, String productId) async {
    try {
      _cart = await _api.decreaseItem(cartId, productId);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> clearCart(String cartId) async {
    _setLoading(true);
    try {
      _cart = await _api.clearCart(cartId);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _cart = null;
    _loading = false;
    _scanning = false;
    _error = null;
    _lastScanned = null;
    notifyListeners();
  }

  void _setLoading(bool val) {
    _loading = val;
    notifyListeners();
  }
}
