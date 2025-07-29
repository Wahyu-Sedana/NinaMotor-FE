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

String formatIDR(dynamic value) {
  final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');
  return formatCurrency.format(value);
}

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();
