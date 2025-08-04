import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/features/pembayaran/data/models/checout_model.dart';
import 'package:intl/intl.dart';

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

String getPaymentMethodDisplay(String method, MidtransData? midtransData) {
  if (midtransData?.paymentType != null) {
    switch (midtransData!.paymentType!.toLowerCase()) {
      case 'bank_transfer':
        return 'Transfer Bank${midtransData.bank != null ? ' (${midtransData.bank!.toUpperCase()})' : ''}';
      case 'gopay':
        return 'GoPay';
      case 'shopeepay':
        return 'ShopeePay';
      case 'qris':
        return 'QRIS';
      case 'credit_card':
        return 'Kartu Kredit';
      default:
        return midtransData.paymentType!.replaceAll('_', ' ').toUpperCase();
    }
  }
  return method.toUpperCase();
}

IconData getStatusIcon(String status) {
  switch (status.toLowerCase()) {
    case 'berhasil':
    case 'settlement':
      return Icons.check_circle;
    case 'pending':
      return Icons.access_time;
    case 'gagal':
    case 'expired':
    case 'cancel':
    case 'deny':
      return Icons.cancel;
    default:
      return Icons.help;
  }
}
