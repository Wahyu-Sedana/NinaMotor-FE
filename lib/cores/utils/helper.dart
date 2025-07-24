import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

final formatCurrency = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
