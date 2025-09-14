import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/cores/services/app_config.dart';
import 'package:frontend/cores/utils/colors.dart';
import 'package:frontend/cores/utils/enum.dart';
import 'package:frontend/cores/utils/helper.dart';
import 'package:frontend/cores/utils/injection.dart';
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
  bool _isLoading = false;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.bank_transfer;

  Future<void> bayarSekarang(
    BuildContext context,
    List<CartItem> selectedItems,
    int total,
  ) async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_selectedPaymentMethod == PaymentMethod.cash) {
        await _processCashPayment(context, selectedItems, total);
      } else {
        await _processTransferPayment(context, selectedItems, total);
      }
    } catch (e) {
      logger('Unexpected error in bayarSekarang: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _processCashPayment(
    BuildContext context,
    List<CartItem> selectedItems,
    int total,
  ) async {
    await _processRegularPayment(context, selectedItems, total, 'cash');
  }

  Future<void> _processTransferPayment(
    BuildContext context,
    List<CartItem> selectedItems,
    int total,
  ) async {
    await _processRegularPayment(
        context, selectedItems, total, 'bank_transfer');
  }

  Future<void> _processRegularPayment(
    BuildContext context,
    List<CartItem> selectedItems,
    int total,
    String metodePembayaran,
  ) async {
    final dio = Dio();
    final session = locator<Session>();

    logger('Processing regular payment with method: $metodePembayaran');

    try {
      final response = await dio.post('${AppConfig.baseURL}transaksi/create',
          data: {
            'user_id': session.getIdUser,
            'total': total,
            'nama': session.getUsername,
            'email': session.getEmail,
            'telepon': '08123456789',
            'metode_pembayaran': metodePembayaran,
            'alamat': '',
            'cart_items': selectedItems.map((item) => item.toJson()).toList(),
          },
          options: Options(headers: {
            'Authorization': 'Bearer ${session.getToken}',
            'Accept': 'application/json',
          }));

      final json = response.data;
      logger('Regular payment response: ${json.toString()}');

      if (json['success'] == true) {
        final orderId = json['order_id'];

        if (metodePembayaran == 'cash') {
          if (mounted) {
            _showCashPaymentDialog(context, orderId);
          }
        } else {
          // Check if snap_token exists for transfer payments
          final snapToken = json['snap_token'];

          if (snapToken == null || snapToken.isEmpty) {
            throw Exception(
                'Snap token tidak ditemukan untuk payment transfer');
          }

          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const AlertDialog(
                content: Row(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 16),
                    Text('Memproses pembayaran...'),
                  ],
                ),
              ),
            );
          }

          if (mounted) {
            Navigator.of(context).pop();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Transaksi berhasil dibuat! ID: $orderId'),
              ),
            );
          }
        }
      } else {
        throw Exception(json['message'] ?? 'Gagal membuat transaksi');
      }
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  void _handleDioException(DioException e) {
    String errorMessage = 'Gagal membuat transaksi';

    logger('DioException occurred: ${e.toString()}');
    logger('Response data: ${e.response?.data}');
    logger('Response status: ${e.response?.statusCode}');

    if (e.response?.data != null) {
      final errorData = e.response!.data;
      if (errorData['message'] != null) {
        errorMessage = errorData['message'];
      } else if (errorData['errors'] != null) {
        final errors = errorData['errors'] as Map<String, dynamic>;
        errorMessage = errors.values.first.first ?? errorMessage;
      }
    } else if (e.message != null) {
      errorMessage = e.message!;
    }

    logger('Payment error: $errorMessage');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
        ),
      );
    }
  }

  void _showCashPaymentDialog(BuildContext context, String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 12),
              Text('Pesanan Berhasil!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Silahkan datang ke toko untuk melakukan pembayaran tunai.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ID Pesanan Anda:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            orderId,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.copy, size: 20),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: orderId));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('ID pesanan disalin!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tunjukkan ID pesanan ini kepada kasir saat datang ke toko.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('OK, Mengerti'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pilih Metode Pembayaran',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          _buildPaymentMethodTile(
            PaymentMethod.bank_transfer,
            'Transfer Bank',
            'Bayar menggunakan transfer bank',
            Icons.account_balance,
            Colors.blue,
          ),
          SizedBox(height: 8),
          _buildPaymentMethodTile(
            PaymentMethod.cash,
            'Bayar di Toko',
            'Bayar tunai langsung di toko',
            Icons.store,
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodTile(
    PaymentMethod method,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedPaymentMethod == method;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: Offset(0, 3),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 24)
            else
              Icon(Icons.radio_button_unchecked,
                  color: Colors.grey[400], size: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
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
                            '${AppConfig.baseURLImage}${item.gambar}',
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
                              Text('Qty: ${item.quantity}',
                                  style: TextStyle(color: Colors.grey[600])),
                              Text(formatIDR(double.parse(item.hargaJual)),
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 12)),
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
            _buildPaymentMethodSelector(),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Subtotal (${widget.cartItems.length} item)',
                          style: TextStyle(color: Colors.grey[600])),
                      Text(formatIDR(widget.total),
                          style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Pembayaran',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(formatIDR(widget.total),
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading
                  ? null
                  : () {
                      bayarSekarang(context, widget.cartItems, widget.total);
                    },
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(
                      _selectedPaymentMethod == PaymentMethod.cash
                          ? Icons.store
                          : Icons.payment,
                      color: white),
              label: Text(_isLoading
                  ? 'Memproses...'
                  : _selectedPaymentMethod == PaymentMethod.cash
                      ? 'Buat Pesanan'
                      : 'Bayar Sekarang'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isLoading ? Colors.grey : Colors.red,
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
