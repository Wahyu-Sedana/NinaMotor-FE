import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/cores/services/app_config.dart';
import 'package:frontend/cores/utils/colors.dart';
import 'package:frontend/cores/utils/helper.dart';
import 'package:frontend/cores/utils/injection.dart';
import 'package:frontend/cores/utils/midtrans_helper.dart';
import 'package:frontend/cores/utils/session.dart';
import 'package:frontend/features/home/data/models/cart_model.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final int total;
  const CheckoutScreen(
      {super.key, required this.cartItems, required this.total});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  Future<void> bayarSekarang(
    BuildContext context,
    List<CartItem> selectedItems,
    int total,
  ) async {
    try {
      final dio = Dio();
      final session = locator<Session>();
      final response = await dio.post('${baseURL}transaksi/create',
          data: {
            'user_id': session.getIdUser,
            'total': total,
            'nama': session.getUsername,
            'email': session.getEmail,
            'telepon': '08123456789',
            'metode_pembayaran': 'midtrans',
            'cart_items': selectedItems
                .map((item) => {
                      'id': item.sparepartId,
                      'nama': item.nama,
                      'harga': item.hargaJual,
                      'quantity': item.quantity,
                    })
                .toList(),
          },
          options: Options(headers: {
            'Authorization': 'Bearer ${session.getToken}',
            'Accept': 'application/json',
          }));

      final json = response.data;

      if (json['success'] == true) {
        final snapToken = json['snap_token'];

        await MidtransHelper.startPayment(snapToken);
      } else {
        throw Exception('Gagal membuat transaksi');
      }
    } catch (e) {
      logger(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal bayar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Detail Pembelian',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) {
                  final item = widget.cartItems[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            'http://127.0.0.1:8000/storage/${item.gambar}',
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.image_not_supported),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.nama,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Text('Qty: ${item.quantity}'),
                            ],
                          ),
                        ),
                        Text(formatIDR(item.subtotal),
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black87)),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(formatIDR(widget.total),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                bayarSekarang(context, widget.cartItems, widget.total);
              },
              icon: const Icon(
                Icons.payment,
                color: white,
              ),
              label: const Text('Bayar Sekarang'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            const SizedBox(height: 26),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF9F4F8),
    );
  }
}
