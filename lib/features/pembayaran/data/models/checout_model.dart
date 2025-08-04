class Transaction {
  final String id;
  final String userId;
  final DateTime tanggalTransaksi;
  final String total;
  final String statusPembayaran;
  final String statusTransaksi;
  final String metodePembayaran;
  final String? alamat;
  final String? snapToken;
  final MidtransData? midtransData;

  Transaction({
    required this.id,
    required this.userId,
    required this.tanggalTransaksi,
    required this.total,
    required this.statusPembayaran,
    required this.statusTransaksi,
    required this.metodePembayaran,
    this.alamat,
    this.snapToken,
    this.midtransData,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? "",
      userId: json['user_id'] ?? "",
      tanggalTransaksi: json['tanggal_transaksi'] != null
          ? DateTime.parse(json['tanggal_transaksi'])
          : DateTime.now(),
      total: json['total'] ?? "",
      statusPembayaran: json['status_pembayaran'] ?? "",
      statusTransaksi: json['status_transaksi'] ?? "",
      metodePembayaran: json['metode_pembayaran'] ?? "",
      alamat: json['alamat'],
      snapToken: json['snap_token'],
      midtransData: json['midtrans_data'] != null
          ? MidtransData.fromJson(json['midtrans_data'])
          : null,
    );
  }
}

class MidtransData {
  final String? transactionStatus;
  final String? paymentType;
  final String? transactionTime;
  final String? settlementTime;
  final String? bank;
  final String? _vaNumber;
  final String? fraudStatus;
  final String? currency;

  MidtransData({
    this.transactionStatus,
    this.paymentType,
    this.transactionTime,
    this.settlementTime,
    this.bank,
    String? vaNumber,
    this.fraudStatus,
    this.currency,
  }) : _vaNumber = vaNumber;

  String? get vaNumber => transactionStatus == 'pending' ? _vaNumber : null;

  factory MidtransData.fromJson(Map<String, dynamic> json) {
    String? extractedBank;
    String? extractedVaNumber;

    if (json['va_numbers'] != null &&
        json['va_numbers'] is List &&
        (json['va_numbers'] as List).isNotEmpty) {
      final firstVa = (json['va_numbers'] as List).first;
      if (firstVa is Map<String, dynamic>) {
        extractedBank = firstVa['bank'];
        extractedVaNumber = firstVa['va_number'];
      }
    }

    return MidtransData(
      transactionStatus: json['transaction_status'],
      paymentType: json['payment_type'],
      transactionTime: json['transaction_time'],
      settlementTime: json['settlement_time'],
      bank: extractedBank ?? json['bank'], // fallback jika ada
      vaNumber: extractedVaNumber ?? json['va_number'], // fallback juga
      fraudStatus: json['fraud_status'],
      currency: json['currency'],
    );
  }
}
