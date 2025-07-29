class CartItem {
  final String sparepartId;
  final int quantity;
  final String nama;
  final String hargaJual;
  final String gambar;

  CartItem({
    required this.sparepartId,
    required this.quantity,
    required this.nama,
    required this.hargaJual,
    required this.gambar,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      sparepartId: json['sparepart_id'] ?? "",
      quantity: json['quantity'] ?? 0,
      nama: json['nama'] ?? "",
      hargaJual: json['harga_jual'] ?? "",
      gambar: json['gambar'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sparepart_id': sparepartId,
      'quantity': quantity,
      'nama': nama,
      'harga_jual': hargaJual,
      'gambar': gambar,
    };
  }
}

class CartModel {
  final String id;
  final String? userId;
  final String? sessionToken;
  final List<CartItem> items;
  final String createdAt;
  final String updatedAt;

  CartModel({
    required this.id,
    this.userId,
    this.sessionToken,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    List<CartItem> parsedItems = [];

    if (json['items'] is List) {
      parsedItems = (json['items'] as List)
          .map((item) => CartItem.fromJson(item ?? {}))
          .toList();
    }

    return CartModel(
      id: json['id']?.toString() ?? "",
      userId: json['user_id']?.toString(),
      sessionToken: json['session_token']?.toString(),
      items: parsedItems,
      createdAt: json['created_at']?.toString() ?? "",
      updatedAt: json['updated_at']?.toString() ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'session_token': sessionToken,
      'items': items.map((e) => e.toJson()).toList(),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class CartResponse {
  final bool success;
  final String message;
  final CartModel? data;

  CartResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    return CartResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? "",
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? CartModel.fromJson(json['data'])
          : null,
    );
  }
}
