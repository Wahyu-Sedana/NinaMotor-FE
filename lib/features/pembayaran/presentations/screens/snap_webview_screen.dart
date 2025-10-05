import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:frontend/cores/utils/helper.dart';

class SnapWebViewScreen extends StatefulWidget {
  final String snapToken;
  final bool isProduction;
  final Function(Map<String, dynamic> result)? onPaymentResult;

  const SnapWebViewScreen({
    super.key,
    required this.snapToken,
    this.isProduction = false,
    this.onPaymentResult,
  });

  @override
  State<SnapWebViewScreen> createState() => _SnapWebViewScreenState();
}

class _SnapWebViewScreenState extends State<SnapWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  double _loadingProgress = 0;
  String? _currentUrl;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    logger('Snap Token: ${widget.snapToken}');
    _initializeWebView();
  }

  String get _snapUrl {
    final baseUrl = widget.isProduction
        ? 'https://app.midtrans.com'
        : 'https://app.sandbox.midtrans.com';
    return '$baseUrl/snap/v3/redirection/${widget.snapToken}';
  }

  void _initializeWebView() {
    logger('Loading URL: $_snapUrl');

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setUserAgent(
          'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36')
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) {
              setState(() {
                _loadingProgress = progress / 100;
              });
            }
            logger('Progress: $progress%');
          },
          onPageStarted: (url) {
            logger('Page started: $url');
            if (mounted) {
              setState(() {
                _isLoading = true;
                _currentUrl = url;
                _hasError = false;
              });
            }
          },
          onPageFinished: (url) {
            logger('Page finished: $url');
            if (mounted) {
              setState(() {
                _isLoading = false;
                _currentUrl = url;
              });
            }
            _checkPaymentStatus(url);
          },
          onNavigationRequest: (request) {
            logger('Navigation: ${request.url}');
            _checkPaymentStatus(request.url);
            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            logger('Error: ${error.description}, Type: ${error.errorType}');
            if (mounted) {
              setState(() {
                _hasError = true;
                _isLoading = false;
              });
            }
          },
          onHttpError: (error) {
            logger('HTTP Error: ${error.response?.statusCode}');
          },
        ),
      )
      ..loadRequest(Uri.parse(_snapUrl));
  }

  void _checkPaymentStatus(String url) {
    if (url.contains('/finish') ||
        url.contains('status_code=200') ||
        url.contains('transaction_status=settlement') ||
        url.contains('transaction_status=capture')) {
      _handlePaymentResult({
        'status': 'success',
        'message': 'Pembayaran berhasil',
        'url': url,
      });
    } else if (url.contains('status_code=201') ||
        url.contains('transaction_status=pending')) {
      _handlePaymentResult({
        'status': 'pending',
        'message': 'Pembayaran menunggu konfirmasi',
        'url': url,
      });
    } else if (url.contains('/unfinish') ||
        url.contains('transaction_status=cancel')) {
      _handlePaymentResult({
        'status': 'cancelled',
        'message': 'Pembayaran dibatalkan',
        'url': url,
      });
    } else if (url.contains('/error') ||
        url.contains('transaction_status=deny') ||
        url.contains('transaction_status=failure')) {
      _handlePaymentResult({
        'status': 'failed',
        'message': 'Pembayaran gagal',
        'url': url,
      });
    } else if (url.contains('transaction_status=expire')) {
      _handlePaymentResult({
        'status': 'expired',
        'message': 'Pembayaran kadaluarsa',
        'url': url,
      });
    }
  }

  void _handlePaymentResult(Map<String, dynamic> result) {
    logger('Payment result: $result');

    if (widget.onPaymentResult != null) {
      widget.onPaymentResult!(result);
    }

    if (mounted) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.pop(context, result);
        }
      });
    }
  }

  Future<bool> _onWillPop() async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Batalkan Pembayaran?'),
        content: const Text(
          'Apakah Anda yakin ingin membatalkan proses pembayaran?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          title: const Text(
            'Pembayaran',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && mounted) {
                Navigator.pop(context, {
                  'status': 'cancelled',
                  'message': 'Pembayaran dibatalkan',
                });
              }
            },
            icon: const Icon(Icons.close_rounded),
          ),
          actions: [
            if (_currentUrl != null)
              IconButton(
                onPressed: () {
                  logger('Reloading WebView');
                  _controller.reload();
                },
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Muat Ulang',
              ),
          ],
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),

            // Loading indicator
            if (_isLoading && !_hasError)
              Container(
                color: Colors.white,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Memuat halaman pembayaran...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 60),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: _loadingProgress,
                            minHeight: 6,
                            backgroundColor: Colors.grey[200],
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(_loadingProgress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Error state
            if (_hasError && !_isLoading)
              Container(
                color: Colors.white,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.wifi_off_rounded,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Gagal Memuat Halaman',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Pastikan Anda terhubung ke internet dan coba lagi.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _hasError = false;
                                _isLoading = true;
                              });
                              _controller.reload();
                            },
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Coba Lagi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context, {
                                'status': 'cancelled',
                                'message': 'Pembayaran dibatalkan',
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey[700],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: Colors.grey[300]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Kembali'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
