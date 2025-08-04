import 'package:flutter/material.dart';

const Color white = Colors.white;
const Color gray = Color(0xFFF2F2F2);
const Color redColor = Colors.red;
Color getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'berhasil':
    case 'settlement':
      return Colors.green;
    case 'pending':
      return Colors.orange;
    case 'gagal':
    case 'expired':
    case 'cancel':
    case 'deny':
      return Colors.red;
    default:
      return Colors.grey;
  }
}
