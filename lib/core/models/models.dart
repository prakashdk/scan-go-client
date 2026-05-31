// lib/core/models/models.dart

class AuthResponse {
  final String userId;
  final String accessToken;

  AuthResponse({required this.userId, required this.accessToken});

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        userId: json['userId'] ?? '',
        accessToken: json['accessToken'] ?? '',
      );
}

class UserResponse {
  final String id;
  final String? email;
  final String? mobile;
  final bool isAnonymous;

  UserResponse({
    required this.id,
    this.email,
    this.mobile,
    required this.isAnonymous,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) => UserResponse(
        id: json['id'] ?? '',
        email: json['email'],
        mobile: json['mobile'],
        isAnonymous: json['isAnonymous'] ?? true,
      );
}

class CartSummaryResponse {
  final String cartId;
  final String status;
  final String storeId;
  final String? storeName;
  final String? storeAddress;
  final String? storeCode;
  final String? merchantId;
  final String? tenantName;
  final String? tenantSlug;

  CartSummaryResponse({
    required this.cartId,
    required this.status,
    required this.storeId,
    this.storeName,
    this.storeAddress,
    this.storeCode,
    this.merchantId,
    this.tenantName,
    this.tenantSlug,
  });

  factory CartSummaryResponse.fromJson(Map<String, dynamic> json) =>
      CartSummaryResponse(
        cartId: json['cartId'] ?? '',
        status: json['status'] ?? 'ACTIVE',
        storeId: json['storeId'] ?? '',
        storeName: json['storeName'],
        storeAddress: json['storeAddress'],
        storeCode: json['storeCode'],
        merchantId: json['merchantId'],
        tenantName: json['tenantName'],
        tenantSlug: json['tenantSlug'],
      );
}

class CartItemResponse {
  final String productId;
  final String barcode;
  final String name;
  final double price;
  final int quantity;

  CartItemResponse({
    required this.productId,
    required this.barcode,
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory CartItemResponse.fromJson(Map<String, dynamic> json) =>
      CartItemResponse(
        productId: json['productId'] ?? '',
        barcode: json['barcode'] ?? '',
        name: json['name'] ?? '',
        price: (json['price'] ?? 0).toDouble(),
        quantity: json['quantity'] ?? 0,
      );
}

class CartResponse {
  final String cartId;
  final String storeId;
  final List<CartItemResponse> items;

  CartResponse({
    required this.cartId,
    required this.storeId,
    required this.items,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) => CartResponse(
        cartId: json['cartId'] ?? '',
        storeId: json['storeId'] ?? '',
        items: (json['items'] as List? ?? [])
            .map((e) => CartItemResponse.fromJson(e))
            .toList(),
      );

  double get totalAmount =>
      items.fold(0, (sum, item) => sum + item.price * item.quantity);
}

class CartBillItem {
  final String name;
  final int quantity;
  final double price;
  final double total;

  CartBillItem({
    required this.name,
    required this.quantity,
    required this.price,
    required this.total,
  });

  factory CartBillItem.fromJson(Map<String, dynamic> json) => CartBillItem(
        name: json['name'] ?? '',
        quantity: json['quantity'] ?? 0,
        price: (json['price'] ?? 0).toDouble(),
        total: (json['total'] ?? 0).toDouble(),
      );
}

class CartBillResponse {
  final String cartId;
  final String? tenantName;
  final String? storeName;
  final String? storeAddress;
  final String? storeCode;
  final List<CartBillItem> items;
  final double totalAmount;
  final DateTime? generatedAt;

  CartBillResponse({
    required this.cartId,
    this.tenantName,
    this.storeName,
    this.storeAddress,
    this.storeCode,
    required this.items,
    required this.totalAmount,
    this.generatedAt,
  });

  factory CartBillResponse.fromJson(Map<String, dynamic> json) =>
      CartBillResponse(
        cartId: json['cartId'] ?? '',
        tenantName: json['tenantName'],
        storeName: json['storeName'],
        storeAddress: json['storeAddress'],
        storeCode: json['storeCode'],
        items: (json['items'] as List? ?? [])
            .map((e) => CartBillItem.fromJson(e))
            .toList(),
        totalAmount: (json['totalAmount'] ?? 0).toDouble(),
        generatedAt: json['generatedAt'] != null
            ? DateTime.tryParse(json['generatedAt'])
            : null,
      );
}

class OrderItemSnapshot {
  final String productId;
  final String barcode;
  final String name;
  final double price;
  final int quantity;
  final double total;

  OrderItemSnapshot({
    required this.productId,
    required this.barcode,
    required this.name,
    required this.price,
    required this.quantity,
    required this.total,
  });

  factory OrderItemSnapshot.fromJson(Map<String, dynamic> json) =>
      OrderItemSnapshot(
        productId: json['productId'] ?? '',
        barcode: json['barcode'] ?? '',
        name: json['name'] ?? '',
        price: (json['price'] ?? 0).toDouble(),
        quantity: json['quantity'] ?? 0,
        total: (json['total'] ?? 0).toDouble(),
      );
}

class OrderBillResponse {
  final String orderId;
  final String? tenantName;
  final String? storeName;
  final String? storeAddress;
  final String? storeCode;
  final List<OrderItemSnapshot> items;
  final double totalAmount;
  final DateTime? createdAt;

  OrderBillResponse({
    required this.orderId,
    this.tenantName,
    this.storeName,
    this.storeAddress,
    this.storeCode,
    required this.items,
    required this.totalAmount,
    this.createdAt,
  });

  factory OrderBillResponse.fromJson(Map<String, dynamic> json) =>
      OrderBillResponse(
        orderId: json['orderId'] ?? '',
        tenantName: json['tenantName'],
        storeName: json['storeName'],
        storeAddress: json['storeAddress'],
        storeCode: json['storeCode'],
        items: (json['items'] as List? ?? [])
            .map((e) => OrderItemSnapshot.fromJson(e))
            .toList(),
        totalAmount: (json['totalAmount'] ?? 0).toDouble(),
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'])
            : null,
      );
}

class OrderResponse {
  final String id;
  final String? tenantName;
  final String? storeName;
  final String? storeAddress;
  final String? storeCode;
  final double totalAmount;
  final DateTime? createdAt;

  OrderResponse({
    required this.id,
    this.tenantName,
    this.storeName,
    this.storeAddress,
    this.storeCode,
    required this.totalAmount,
    this.createdAt,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) => OrderResponse(
        id: json['id'] ?? '',
        tenantName: json['tenantName'],
        storeName: json['storeName'],
        storeAddress: json['storeAddress'],
        storeCode: json['storeCode'],
        totalAmount: (json['totalAmount'] ?? 0).toDouble(),
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'])
            : null,
      );
}
