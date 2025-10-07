import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/cores/services/app_config.dart';
import 'package:frontend/cores/services/rajaongkir_service.dart';
import 'package:frontend/cores/utils/helper.dart';
import 'package:frontend/cores/utils/injection.dart';
import 'package:frontend/cores/utils/session.dart';
import 'package:frontend/features/home/data/models/cart_model.dart';
import 'package:frontend/features/pembayaran/presentations/screens/select_adress_screen.dart';

enum PurchaseType { delivery, pickup }

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final int total;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.total,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen>
    with SingleTickerProviderStateMixin {
  bool _isProcessing = false;
  PurchaseType _purchaseType = PurchaseType.delivery;

  // Address & Shipping
  Map<String, dynamic>? _selectedAddress;
  int _shippingCost = 0;
  String _selectedCourier = 'jne';
  List<Map<String, dynamic>> _shippingServices = [];
  Map<String, dynamic>? _selectedShippingService;
  bool _isLoadingShipping = false;

  final _session = locator<Session>();
  final _rajaOngkirService = RajaOngkirService();

  // ==================== ADDRESS & SHIPPING METHODS ====================

  Future<void> _selectAddress() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SelectAddressScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedAddress = result;
      });
      _loadShippingCost();
    }
  }

  Future<void> _loadShippingCost() async {
    if (_selectedAddress == null) return;

    final destinationDistrictId = _selectedAddress!['district_id'];

    if (destinationDistrictId == null) {
      _showErrorSnackBar('District ID tidak ditemukan pada alamat ini');
      return;
    }

    setState(() {
      _isLoadingShipping = true;
      _shippingServices = [];
      _selectedShippingService = null;
      _shippingCost = 0;
    });

    try {
      final results = await _rajaOngkirService.getShippingCost(
        originDistrictId: 2175,
        destinationDistrictId: destinationDistrictId,
        weight: 10,
      );

      setState(() {
        _shippingServices = results;
        _isLoadingShipping = false;
        if (results.isNotEmpty) {
          _selectedShippingService = results[0];
          _shippingCost = results[0]['cost'] as int;
        }
      });
    } catch (e) {
      setState(() => _isLoadingShipping = false);
      print('Error get ongkir: $e');
      _showErrorSnackBar('Gagal memuat ongkir: $e');
    }
  }

  void _selectShippingService(Map<String, dynamic> service) {
    setState(() {
      _selectedShippingService = service;
      _shippingCost = service['cost'] as int;
    });
  }

  // ==================== CHECKOUT PROCESS ====================

  Future<void> _processCheckout() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      // Set payment method automatically
      if (_purchaseType == PurchaseType.delivery) {
        await _processBankTransferPayment();
      } else {
        await _processCashPayment();
      }
    } catch (e) {
      logger('Checkout error: $e');
      _showErrorSnackBar('Terjadi kesalahan saat memproses pembayaran');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _processCashPayment() async {
    await _createTransaction('cash');
  }

  Future<void> _processBankTransferPayment() async {
    await _createTransaction('bank_transfer');
  }

  Future<void> _createTransaction(String paymentMethod) async {
    final dio = Dio();

    try {
      Map<String, dynamic> transactionData = {
        'user_id': _session.getIdUser,
        'metode_pembayaran': paymentMethod,
        'cart_items': widget.cartItems.map((item) => item.toJson()).toList(),
      };

      if (_purchaseType == PurchaseType.delivery) {
        if (_selectedAddress == null) {
          _showErrorSnackBar('Silakan pilih alamat pengiriman terlebih dahulu');
          return;
        }

        if (_selectedShippingService == null) {
          _showErrorSnackBar('Silakan pilih metode pengiriman terlebih dahulu');
          return;
        }

        final grandTotal = widget.total + _shippingCost;
        print(grandTotal);

        transactionData.addAll({
          'total': grandTotal,
          'nama': _selectedAddress!['nama_penerima'],
          'email': _session.getEmail,
          'telepon': _selectedAddress!['no_telp_penerima'],
          'alamat': _selectedAddress!['alamat_lengkap'],
          'alamat_id': _selectedAddress!['id'],
          'city_id': _selectedAddress!['city_id'],
          'province_id': _selectedAddress!['province_id'],
          'ongkir': _shippingCost,
          'kurir': _selectedCourier.toUpperCase(),
          'service': _selectedShippingService!['service'],
          'estimasi': _selectedShippingService!['etd'] as String?,
          'type_pembelian': 0,
        });
      } else {
        transactionData.addAll({
          'total': widget.total,
          'nama': _session.getUsername,
          'email': _session.getEmail,
          'telepon': '08123456789',
          'alamat': 'Ambil di Toko',
          'ongkir': 0,
          'type_pembelian': 0,
        });
      }

      final response = await dio.post(
        '${AppConfig.baseURL}transaksi/create',
        data: transactionData,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${_session.getToken}',
            'Accept': 'application/json',
          },
        ),
      );

      final responseData = response.data;
      logger('Transaction response: ${responseData.toString()}');

      if (responseData['success'] == true) {
        final orderId = responseData['order_id'];

        if (paymentMethod == 'cash') {
          _showCashSuccessDialog(orderId);
        } else {
          final snapToken = responseData['snap_token'];

          if (snapToken == null || snapToken.isEmpty) {
            throw Exception('Snap token tidak ditemukan');
          }

          final paymentResult = await openSnapPayment(
            context,
            snapToken,
            isProduction: false,
          );

          if (paymentResult != null) {
            if (paymentResult['status'] == 'success' ||
                paymentResult['status'] == 'pending') {
              _handleTransferSuccess(orderId);
            } else if (paymentResult['status'] == 'cancelled') {
              _showErrorSnackBar('Pembayaran dibatalkan');
            } else if (paymentResult['status'] == 'failed') {
              _showErrorSnackBar('Pembayaran gagal');
            }
          }
        }
      } else {
        throw Exception(responseData['message'] ?? 'Gagal membuat transaksi');
      }
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  void _handleDioException(DioException e) {
    String errorMessage = 'Gagal memproses pembayaran';

    if (e.response?.data != null) {
      final errorData = e.response!.data;
      if (errorData['message'] != null) {
        errorMessage = errorData['message'];
      } else if (errorData['errors'] != null) {
        final errors = errorData['errors'] as Map<String, dynamic>;
        errorMessage = errors.values.first.first ?? errorMessage;
      }
    }

    logger('Payment error: $errorMessage');
    _showErrorSnackBar(errorMessage);
  }

  void _handleTransferSuccess(String orderId) {
    if (!mounted) return;

    Navigator.pop(context);
    _showSuccessSnackBar('Transaksi berhasil dibuat! ID: $orderId');
  }

  // ==================== BUILD UI ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildCheckoutContent()),
          _buildCheckoutBottom(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      title: const Text(
        'Checkout',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
    );
  }

  Widget _buildCheckoutContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPurchaseTypeToggle(),
          const SizedBox(height: 24),

          if (_purchaseType == PurchaseType.delivery) ...[
            _buildAddressSection(),
            const SizedBox(height: 24),
            _buildShippingSection(),
            const SizedBox(height: 24),
          ],

          if (_purchaseType == PurchaseType.pickup) ...[
            _buildStoreInfo(),
            const SizedBox(height: 24),
          ],

          _buildOrderSummary(),
          const SizedBox(height: 24),
          // Payment method widget removed
          _buildPriceBreakdown(),
        ],
      ),
    );
  }

  // ==================== PURCHASE TYPE TOGGLE ====================

  Widget _buildPurchaseTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_mall_rounded, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              const Text(
                'Metode Pengambilan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildPurchaseTypeOption(
                  PurchaseType.delivery,
                  'Diantar',
                  'Kirim ke alamat',
                  Icons.delivery_dining_rounded,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPurchaseTypeOption(
                  PurchaseType.pickup,
                  'Ambil Sendiri',
                  'Di toko',
                  Icons.store_rounded,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseTypeOption(
    PurchaseType type,
    String title,
    String subtitle,
    IconData icon,
    MaterialColor color,
  ) {
    final isSelected = _purchaseType == type;

    return InkWell(
      onTap: () {
        setState(() {
          _purchaseType = type;
          if (type == PurchaseType.pickup) {
            // Reset shipping data
            _selectedAddress = null;
            _shippingCost = 0;
            _selectedShippingService = null;
          }
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.shade50 : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color.shade300 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color.shade700 : Colors.grey[600],
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? color.shade800 : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ==================== ADDRESS SECTION ====================

  Widget _buildAddressSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_rounded, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              const Text(
                'Alamat Pengiriman',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_selectedAddress == null)
            InkWell(
              onTap: _selectAddress,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add_location_rounded,
                        color: Colors.blue.shade600),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Pilih Alamat Pengiriman',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded,
                        size: 16, color: Colors.grey[600]),
                  ],
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedAddress!['nama_penerima'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _selectAddress,
                        child: const Text('Ubah'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedAddress!['no_telp_penerima'],
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedAddress!['alamat_lengkap'],
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_selectedAddress!['city_name']}, ${_selectedAddress!['province_name']}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ==================== SHIPPING SECTION ====================

  Widget _buildShippingSection() {
    if (_selectedAddress == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_shipping_rounded, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              const Text(
                'Pilih Pengiriman',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoadingShipping)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_shippingServices.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Pilih kurir terlebih dahulu',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            )
          else
            ..._shippingServices.map((service) {
              final isSelected = _selectedShippingService == service;
              final cost = service['cost'] as int;
              final etd = service['etd'] as String?;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => _selectShippingService(service),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue.shade50 : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Colors.blue.shade300
                            : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_selectedCourier.toUpperCase()} - ${service['service']}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.blue.shade800
                                      : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                service['description'],
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Estimasi: $etd hari',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              formatIDR(cost.toDouble()),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.blue.shade800
                                    : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: isSelected
                                  ? Colors.blue.shade600
                                  : Colors.grey[400],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  // ==================== STORE INFO (PICKUP) ====================

  Widget _buildStoreInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.store_rounded,
                  color: Colors.orange.shade700,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ambil di Toko',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Silakan datang ke toko kami',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.orange.shade200),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.location_on_rounded,
            'Alamat Toko',
            'Jl. Raya Sesetan No.312, Sesetan, Denpasar Selatan, Kota Denpasar, Bali 80223',
            Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.access_time_rounded,
            'Jam Buka',
            'Senin - Minggu: 08.00 - 17.00 WITA',
            Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.phone_rounded,
            'Telepon',
            '0852-3770-7724',
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    MaterialColor color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: color.shade700),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: color.shade900,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== ORDER SUMMARY ====================

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shopping_bag_rounded, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              const Text(
                'Ringkasan Pesanan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...widget.cartItems.map((item) => _buildOrderItem(item)),
        ],
      ),
    );
  }

  Widget _buildOrderItem(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 50,
              height: 50,
              color: Colors.grey.shade100,
              child: Image.network(
                '${AppConfig.baseURLImage}${item.gambar}',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.image_not_supported_rounded,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nama,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${item.quantity}x',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatIDR(double.parse(item.hargaJual)),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            formatIDR(item.subtotal),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== PRICE BREAKDOWN ====================

  Widget _buildPriceBreakdown() {
    final itemCount = widget.cartItems.length;
    final grandTotal = _purchaseType == PurchaseType.delivery
        ? widget.total + _shippingCost
        : widget.total;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_rounded, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              const Text(
                'Rincian Biaya',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal ($itemCount item)',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              Text(
                formatIDR(widget.total.toDouble()),
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ongkos Kirim',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              Text(
                _purchaseType == PurchaseType.pickup
                    ? 'Gratis'
                    : _shippingCost > 0
                        ? formatIDR(_shippingCost.toDouble())
                        : 'Pilih alamat',
                style: TextStyle(
                  fontSize: 14,
                  color: _purchaseType == PurchaseType.pickup
                      ? Colors.green
                      : _shippingCost > 0
                          ? Colors.grey[700]
                          : Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(height: 24, color: Colors.grey.shade300),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Pembayaran',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                formatIDR(grandTotal.toDouble()),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== CHECKOUT BOTTOM ====================

  Widget _buildCheckoutBottom() {
    final grandTotal = _purchaseType == PurchaseType.delivery
        ? widget.total + _shippingCost
        : widget.total;

    final canCheckout = _purchaseType == PurchaseType.pickup ||
        (_selectedAddress != null && _selectedShippingService != null);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Pembayaran',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    Text(
                      formatIDR(grandTotal.toDouble()),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 160,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: (_isProcessing || !canCheckout)
                        ? null
                        : _processCheckout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      disabledBackgroundColor: Colors.grey[300],
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _purchaseType == PurchaseType.pickup
                                    ? Icons.store_rounded
                                    : Icons.payment_rounded,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _purchaseType == PurchaseType.pickup
                                    ? 'Pesan'
                                    : 'Bayar',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== DIALOGS & SNACKBARS ====================

  void _showCashSuccessDialog(String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: Colors.green.shade600,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Pesanan Berhasil Dibuat!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              _purchaseType == PurchaseType.pickup
                  ? 'Silakan datang ke toko untuk melakukan pembayaran tunai dan mengambil pesanan.'
                  : 'Pesanan Anda akan segera diproses dan dikirim ke alamat tujuan.',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  const Text(
                    'ID Pesanan Anda',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          orderId,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _copyOrderId(orderId),
                        icon: const Icon(Icons.copy_rounded),
                        tooltip: 'Salin ID',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'OK, Mengerti',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyOrderId(String orderId) {
    Clipboard.setData(ClipboardData(text: orderId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ID pesanan berhasil disalin!'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
