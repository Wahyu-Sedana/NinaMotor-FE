import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/features/pembayaran/data/models/checkout_model.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

void logger(dynamic value, {String? label}) {
  if (kDebugMode) {
    if (label != null) {
      print('[DEBUG][$label] => $value');
    } else {
      print('[DEBUG] => $value');
    }
  }
}

String formatIDR(dynamic value) {
  final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');
  return formatCurrency.format(value);
}

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

String formatDateIndonesia(DateTime date) {
  const List<String> months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember'
  ];

  final day = date.day;
  final month = months[date.month - 1];
  final year = date.year;
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');

  return '$day $month $year, $hour:$minute';
}

String getPaymentMethodDisplay(
    String metodePembayaran, PaymentInfo? paymentInfo) {
  if (paymentInfo?.paymentType != null) {
    return _formatPaymentType(paymentInfo!.paymentType!);
  }

  if (metodePembayaran == 'pending') {
    return 'Belum Dipilih';
  }

  return _formatPaymentType(metodePembayaran);
}

String _formatPaymentType(String paymentType) {
  switch (paymentType.toLowerCase()) {
    case 'bank_transfer':
      return 'Transfer Bank';
    case 'credit_card':
      return 'Kartu Kredit';
    case 'gopay':
      return 'GoPay';
    case 'shopeepay':
      return 'ShopeePay';
    case 'qris':
      return 'QRIS';
    case 'echannel':
      return 'Mandiri Bill';
    case 'bca_va':
      return 'BCA Virtual Account';
    case 'bni_va':
      return 'BNI Virtual Account';
    case 'bri_va':
      return 'BRI Virtual Account';
    case 'mandiri_va':
      return 'Mandiri Virtual Account';
    case 'other_va':
      return 'Virtual Account';
    case 'pending':
      return 'Belum Dipilih';
    default:
      return paymentType.replaceAll('_', ' ').toUpperCase();
  }
}

IconData getStatusIcon(String status) {
  switch (status.toLowerCase()) {
    case 'berhasil':
    case 'settlement':
      return Icons.check_circle;
    case 'pending':
      return Icons.access_time;
    case 'expired':
    case 'cancel':
    case 'deny':
      return Icons.cancel;
    default:
      return Icons.help;
  }
}

int _getTotalItemsCount(Transaction transaction) {
  if (transaction.cartItems == null) return 0;
  return transaction.cartItems!
      .fold<int>(0, (sum, item) => sum + (item.quantity));
}

String getItemsPreview(Transaction transaction) {
  if (transaction.cartItems == null || transaction.cartItems!.isEmpty) {
    return 'Tidak ada item';
  }

  if (transaction.cartItems!.length == 1) {
    final item = transaction.cartItems!.first;
    return '${item.nama} (${item.quantity}x)';
  } else {
    final firstItem = transaction.cartItems!.first;
    final totalItems = _getTotalItemsCount(transaction);
    return '${firstItem.nama} dan ${transaction.cartItems!.length - 1} item lainnya ($totalItems total)';
  }
}

Future<void> openSnapPayment(String snapToken,
    {bool isProduction = false}) async {
  final baseUrl = isProduction
      ? 'https://app.midtrans.com/snap/v2/vtweb/'
      : 'https://app.sandbox.midtrans.com/snap/v2/vtweb/';
  final url = Uri.parse('$baseUrl$snapToken');

  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } else {
    throw Exception('Tidak bisa membuka URL pembayaran');
  }
}
