// lib/core/api/api_service.dart

import 'api_client.dart';
import '../models/models.dart';

class ApiService {
  final ApiClient _client = ApiClient();

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<AuthResponse> loginAnonymous() async {
    final res = await _client.post('/api/v1/users/anonymous');
    final data = _client.parseResponse(res);
    final auth = AuthResponse.fromJson(data);
    await _client.setToken(auth.accessToken);
    return auth;
  }

  Future<AuthResponse> authenticate(String email, String password) async {
    final res = await _client.post('/api/v1/users/auth', body: {
      'email': email,
      'password': password,
    });
    final data = _client.parseResponse(res);
    final auth = AuthResponse.fromJson(data);
    await _client.setToken(auth.accessToken);
    return auth;
  }

  Future<AuthResponse> upgradeAccount({
    required String email,
    required String password,
    String? mobile,
  }) async {
    final res = await _client.post('/api/v1/users/upgrade', body: {
      'email': email,
      'password': password,
      if (mobile != null) 'mobile': mobile,
    });
    final data = _client.parseResponse(res);
    final auth = AuthResponse.fromJson(data);
    await _client.setToken(auth.accessToken);
    return auth;
  }

  Future<UserResponse> getMe() async {
    final res = await _client.get('/api/v1/users/me');
    final data = _client.parseResponse(res);
    return UserResponse.fromJson(data);
  }

  Future<void> logout() async {
    await _client.clearToken();
  }

  // ── Carts ─────────────────────────────────────────────────────────────────

  Future<CartSummaryResponse> getOrCreateCart(String storeCode) async {
    final res = await _client.post('/api/v1/carts/store/$storeCode');
    final data = _client.parseResponse(res);
    return CartSummaryResponse.fromJson(data);
  }

  Future<List<CartSummaryResponse>> getMyCarts() async {
    final res = await _client.get('/api/v1/carts');
    final data = _client.parseResponse(res) as List;
    return data.map((e) => CartSummaryResponse.fromJson(e)).toList();
  }

  Future<CartResponse> getCart(String cartId) async {
    final res = await _client.get('/api/v1/carts/$cartId');
    final data = _client.parseResponse(res);
    return CartResponse.fromJson(data);
  }

  Future<CartResponse> addItem(String cartId, String barcode) async {
    final res = await _client
        .post('/api/v1/carts/$cartId/items?barcode=${Uri.encodeComponent(barcode)}');
    final data = _client.parseResponse(res);
    return CartResponse.fromJson(data);
  }

  Future<CartResponse> decreaseItem(String cartId, String productId) async {
    final res =
        await _client.delete('/api/v1/carts/$cartId/items/$productId');
    final data = _client.parseResponse(res);
    return CartResponse.fromJson(data);
  }

  Future<CartResponse> clearCart(String cartId) async {
    final res = await _client.delete('/api/v1/carts/$cartId/items');
    final data = _client.parseResponse(res);
    return CartResponse.fromJson(data);
  }

  Future<CartBillResponse> getCartBill(String cartId) async {
    final res = await _client.get('/api/v1/carts/$cartId/bill');
    final data = _client.parseResponse(res);
    return CartBillResponse.fromJson(data);
  }

  // ── Orders ────────────────────────────────────────────────────────────────

  Future<void> checkout(String cartId) async {
    final res = await _client.post('/api/v1/orders/checkout/$cartId');
    _client.parseResponse(res);
  }

  Future<List<OrderResponse>> getMyOrders() async {
    final res = await _client.get('/api/v1/orders/my');
    final data = _client.parseResponse(res) as List;
    return data.map((e) => OrderResponse.fromJson(e)).toList();
  }

  Future<OrderBillResponse> getOrderBill(String orderId) async {
    final res = await _client.get('/api/v1/orders/$orderId/bill');
    final data = _client.parseResponse(res);
    return OrderBillResponse.fromJson(data);
  }
}
