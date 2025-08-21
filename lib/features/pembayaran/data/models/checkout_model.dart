class Transaction {
  final String id;
  final String userId;
  final DateTime tanggalTransaksi;
  final String total;
  final String statusPembayaran;
  final String metodePembayaran;
  final String type_transaction;
  final String? alamat;
  final String? snapToken;
  final List<CartItem>? cartItems;
  final PaymentInstruction? paymentInstruction;
  final PaymentInfo? paymentInfo;

  Transaction({
    required this.id,
    required this.userId,
    required this.tanggalTransaksi,
    required this.total,
    required this.statusPembayaran,
    required this.metodePembayaran,
    required this.type_transaction,
    this.alamat,
    this.snapToken,
    this.cartItems,
    this.paymentInstruction,
    this.paymentInfo,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    List<CartItem>? parsedCartItems;
    if (json['cart_items'] != null) {
      parsedCartItems = (json['cart_items'] as List)
          .map((item) => CartItem.fromTransactionJson(item))
          .toList();
    }

    PaymentInstruction? paymentInstruction;
    if (json['payment_instruction'] != null) {
      paymentInstruction =
          PaymentInstruction.fromJson(json['payment_instruction']);
    }

    PaymentInfo? paymentInfo;
    if (json['payment_info'] != null) {
      paymentInfo = PaymentInfo.fromJson(json['payment_info']);
    }

    return Transaction(
      id: json['id'] ?? "",
      userId: json['user_id'] ?? "",
      tanggalTransaksi: json['tanggal_transaksi'] != null
          ? DateTime.parse(json['tanggal_transaksi'])
          : DateTime.now(),
      total: json['total']?.toString() ?? "0",
      type_transaction: json['tipe_transaksi'] ?? "",
      statusPembayaran: json['status_pembayaran'] ?? "",
      metodePembayaran: json['metode_pembayaran'] ?? "",
      alamat: json['alamat'],
      snapToken: json['snap_token'],
      cartItems: parsedCartItems,
      paymentInstruction: paymentInstruction,
      paymentInfo: paymentInfo,
    );
  }
}

class PaymentInstruction {
  final String bank;
  final String vaNumber;
  final String? paymentType;

  PaymentInstruction({
    required this.bank,
    required this.vaNumber,
    this.paymentType,
  });

  factory PaymentInstruction.fromJson(Map<String, dynamic> json) {
    return PaymentInstruction(
      bank: json['bank'] ?? "",
      vaNumber: json['va_number'] ?? "",
      paymentType: json['payment_type'],
    );
  }
}

class PaymentInfo {
  final String? paymentType;
  final String? transactionTime;
  final String? transactionStatus;
  final String? lastUpdated;

  PaymentInfo({
    this.paymentType,
    this.transactionTime,
    this.transactionStatus,
    this.lastUpdated,
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      paymentType: json['payment_type'],
      transactionTime: json['transaction_time'],
      transactionStatus: json['transaction_status'],
      lastUpdated: json['last_updated'],
    );
  }
}

class CartItem {
  final String sparepartId;
  final String nama;
  final int hargaJual;
  final int quantity;
  final String? gambar;

  CartItem({
    required this.sparepartId,
    required this.nama,
    required this.hargaJual,
    required this.quantity,
    this.gambar,
  });

  int get subtotal => hargaJual * quantity;

  factory CartItem.fromTransactionJson(Map<String, dynamic> json) {
    return CartItem(
      sparepartId: json['id']?.toString() ?? "",
      nama: json['nama'] ?? "",
      hargaJual: int.tryParse(json['harga']?.toString() ?? "0") ?? 0,
      quantity: int.tryParse(json['quantity']?.toString() ?? "1") ?? 1,
      gambar: json['gambar'],
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      sparepartId: json['sparepart_id']?.toString() ?? "",
      nama: json['nama'] ?? "",
      hargaJual: int.tryParse(json['harga_jual']?.toString() ?? "0") ?? 0,
      quantity: int.tryParse(json['quantity']?.toString() ?? "1") ?? 1,
      gambar: json['gambar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': sparepartId,
      'nama': nama,
      'harga': hargaJual,
      'quantity': quantity,
    };
  }
}
