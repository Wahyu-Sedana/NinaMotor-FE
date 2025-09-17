import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/cores/utils/colors.dart';
import 'package:frontend/cores/utils/helper.dart';
import 'package:frontend/cores/utils/injection.dart';
import 'package:frontend/cores/utils/session.dart';
import 'package:frontend/features/pembayaran/data/models/checkout_model.dart';
import 'package:frontend/features/pembayaran/presentations/bloc/checkout_bloc.dart';
import 'package:frontend/features/pembayaran/presentations/bloc/event/checkout_event.dart';
import 'package:frontend/features/pembayaran/presentations/bloc/state/checkout_state.dart';
import 'package:frontend/features/pembayaran/presentations/widgets/widget_detail_history.dart';
import 'package:frontend/features/pembayaran/presentations/widgets/widget_history_shimer.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen>
    with SingleTickerProviderStateMixin {
  // Data management
  List<Transaction> _transactions = [];
  bool _hasMore = true;
  int _currentOffset = 0;
  static const int _limit = 20;
  String _selectedStatus = 'all';

  // Controllers
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Services
  final _session = locator<Session>();

  // States
  bool _isRefreshing = false;
  bool _isLoadingMore = false;
  bool _isInitialLoad = true;

  // Filter options
  static const List<Map<String, String>> _filterOptions = [
    {'value': 'all', 'label': 'Semua Status', 'icon': 'all'},
    {'value': 'pending', 'label': 'Pending', 'icon': 'pending'},
    {'value': 'berhasil', 'label': 'Berhasil', 'icon': 'success'},
    {'value': 'expired', 'label': 'Expired', 'icon': 'expired'},
    {'value': 'gagal', 'label': 'Gagal', 'icon': 'failed'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupScrollController();
    _loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  void _setupScrollController() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (!_isLoadingMore && _hasMore && !_isRefreshing) {
          _loadMoreTransactions();
        }
      }
    });
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadTransactions(isInitial: true);
      }
    });
  }

  void _loadTransactions({bool isRefresh = false, bool isInitial = false}) {
    if (isRefresh || isInitial) {
      setState(() {
        if (isRefresh) _isRefreshing = true;
        if (isInitial) _isInitialLoad = true;
        _transactions.clear();
        _currentOffset = 0;
        _hasMore = true;
        _isLoadingMore = false;
      });
    }

    context.read<CheckoutBloc>().add(GetCheckoutListEvent(
          userId: _session.getIdUser,
          limit: _limit,
          offset: _currentOffset,
          status: _selectedStatus == 'all' ? null : _selectedStatus,
        ));
  }

  void _loadMoreTransactions() {
    if (!_hasMore || _isLoadingMore) return;

    setState(() => _isLoadingMore = true);

    context.read<CheckoutBloc>().add(GetCheckoutListEvent(
          userId: _session.getIdUser,
          limit: _limit,
          offset: _currentOffset,
          status: _selectedStatus == 'all' ? null : _selectedStatus,
        ));
  }

  Future<void> _refreshTransactions() async {
    if (_isRefreshing) return;
    _loadTransactions(isRefresh: true);
  }

  void _onStatusFilterChanged(String status) {
    if (_selectedStatus == status) return;

    setState(() => _selectedStatus = status);
    _loadTransactions(isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildFilterChips(),
            _buildTransactionStats(),
            Expanded(
              child: BlocConsumer<CheckoutBloc, CheckoutState>(
                listener: _handleBlocState,
                builder: (context, state) => _buildTransactionContent(state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      title: const Text(
        'Riwayat Transaksi',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      actions: [
        IconButton(
          onPressed: _refreshTransactions,
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filterOptions.length,
        itemBuilder: (context, index) {
          final filter = _filterOptions[index];
          final isSelected = _selectedStatus == filter['value'];

          return Container(
            margin: EdgeInsets.only(
                right: index < _filterOptions.length - 1 ? 8 : 0),
            child: FilterChip(
              label: Text(filter['label']!),
              selected: isSelected,
              onSelected: (_) => _onStatusFilterChanged(filter['value']!),
              backgroundColor: Colors.white,
              selectedColor: Colors.blue.shade50,
              checkmarkColor: Colors.blue.shade600,
              labelStyle: TextStyle(
                color: isSelected ? Colors.blue.shade700 : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
              side: BorderSide(
                color: isSelected ? Colors.blue.shade300 : Colors.grey.shade300,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionStats() {
    if (_transactions.isEmpty) return const SizedBox.shrink();

    final stats = _calculateStats();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem('Total', '${stats['total']}', Colors.blue),
          ),
          Container(width: 1, height: 30, color: Colors.grey.shade300),
          Expanded(
            child:
                _buildStatItem('Berhasil', '${stats['success']}', Colors.green),
          ),
          Container(width: 1, height: 30, color: Colors.grey.shade300),
          Expanded(
            child:
                _buildStatItem('Pending', '${stats['pending']}', Colors.orange),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, MaterialColor color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color.shade600,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Map<String, int> _calculateStats() {
    return {
      'total': _transactions.length,
      'success': _transactions
          .where((t) => t.statusPembayaran.toLowerCase() == 'berhasil')
          .length,
      'pending': _transactions
          .where((t) => t.statusPembayaran.toLowerCase() == 'pending')
          .length,
    };
  }

  void _handleBlocState(BuildContext context, CheckoutState state) {
    switch (state.runtimeType) {
      case const (CheckoutLoaded):
        _handleSuccessState(state as CheckoutLoaded);
        break;
      case const (CheckoutError):
        _handleErrorState(state as CheckoutError);
        break;
    }
  }

  void _handleSuccessState(CheckoutLoaded state) {
    final newTransactions = state.data;

    setState(() {
      if (_currentOffset == 0) {
        _transactions = List.from(newTransactions);
      } else {
        for (var newTransaction in newTransactions) {
          if (!_transactions.any((t) => t.id == newTransaction.id)) {
            _transactions.add(newTransaction);
          }
        }
      }

      _hasMore = newTransactions.length == _limit;
      _currentOffset = _transactions.length;
      _isRefreshing = false;
      _isLoadingMore = false;
      _isInitialLoad = false;
    });
  }

  void _handleErrorState(CheckoutError state) {
    setState(() {
      _isRefreshing = false;
      _isLoadingMore = false;
      _isInitialLoad = false;
    });

    if (!_isRefreshing) {
      _showErrorSnackBar(state.failure.message);
    }
  }

  Widget _buildTransactionContent(CheckoutState state) {
    if (_isInitialLoad && _transactions.isEmpty) {
      return const ShimmerTransactionList();
    }

    if (state is CheckoutError && _transactions.isEmpty) {
      return _buildErrorState(state.failure.message);
    }

    if (_transactions.isEmpty && state is CheckoutLoaded) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refreshTransactions,
      child: _isRefreshing
          ? const ShimmerTransactionList()
          : _buildTransactionList(),
    );
  }

  Widget _buildErrorState(String message) {
    return RefreshIndicator(
      onRefresh: _refreshTransactions,
      child: ListView(
        children: [
          const SizedBox(height: 100),
          Center(
            child: Column(
              children: [
                Icon(Icons.error_outline_rounded,
                    size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                const Text(
                  'Gagal Memuat Transaksi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _refreshTransactions,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: _refreshTransactions,
      child: ListView(
        children: [
          const SizedBox(height: 100),
          Center(
            child: Column(
              children: [
                Icon(Icons.receipt_long_rounded,
                    size: 80, color: Colors.grey[300]),
                const SizedBox(height: 24),
                const Text(
                  'Belum Ada Transaksi',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedStatus == 'all'
                      ? 'Riwayat transaksi Anda akan muncul di sini'
                      : 'Tidak ada transaksi dengan status ${_selectedStatus}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _transactions.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _transactions.length) {
          return _buildLoadMoreIndicator();
        }

        final transaction = _transactions[index];
        return _buildTransactionCard(transaction);
      },
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoadingMore
            ? Column(
                children: const [
                  ShimmerTransactionCard(),
                  ShimmerTransactionCard(),
                ],
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    final statusColor = getStatusColor(transaction.statusPembayaran);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () =>
            showTransactionDetail(context: context, transaction: transaction),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTransactionHeader(transaction, statusColor),
              const SizedBox(height: 12),
              _buildTransactionDetails(transaction),
              const SizedBox(height: 12),
              _buildTransactionFooter(transaction),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionHeader(Transaction transaction, Color statusColor) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order #${transaction.id}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                formatDateIndonesia(transaction.tanggalTransaksi),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                getStatusIcon(transaction.statusPembayaran),
                size: 14,
                color: statusColor,
              ),
              const SizedBox(width: 4),
              Text(
                transaction.statusPembayaran.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionDetails(Transaction transaction) {
    return Column(
      children: [
        _buildDetailRow(
          Icons.shopping_bag_rounded,
          getItemsPreview(transaction),
        ),
        const SizedBox(height: 6),
        _buildDetailRow(
          Icons.payment_rounded,
          getPaymentMethodDisplay(
              transaction.metodePembayaran, transaction.paymentInfo),
        ),
        if (transaction.paymentInstruction != null) ...[
          const SizedBox(height: 6),
          _buildDetailRow(
            Icons.account_balance_rounded,
            '${transaction.paymentInstruction!.bank} VA: ${transaction.paymentInstruction!.vaNumber}',
            isMonospace: true,
          ),
        ],
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String text,
      {bool isMonospace = false}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 13,
              fontFamily: isMonospace ? 'monospace' : null,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionFooter(Transaction transaction) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '(${transaction.cartItems!.length} item)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          Text(
            formatIDR(double.tryParse(transaction.total)),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.green,
            ),
          ),
        ],
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
        action: SnackBarAction(
          label: 'Coba Lagi',
          textColor: Colors.white,
          onPressed: _refreshTransactions,
        ),
      ),
    );
  }
}
