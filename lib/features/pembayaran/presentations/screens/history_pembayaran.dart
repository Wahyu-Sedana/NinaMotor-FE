import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/cores/utils/colors.dart';
import 'package:frontend/cores/utils/helper.dart';
import 'package:frontend/cores/utils/injection.dart';
import 'package:frontend/cores/utils/session.dart';
import 'package:frontend/features/pembayaran/data/models/checout_model.dart';
import 'package:frontend/features/pembayaran/presentations/bloc/checkout_bloc.dart';
import 'package:frontend/features/pembayaran/presentations/bloc/event/checkout_event.dart';
import 'package:frontend/features/pembayaran/presentations/bloc/state/checkout_state.dart';
import 'package:frontend/features/pembayaran/presentations/widgets/widget_detail_history.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  List<Transaction> transactions = [];
  bool hasMore = true;
  int currentOffset = 0;
  final int limit = 20;
  String selectedStatus = 'all';
  final ScrollController _scrollController = ScrollController();
  final session = locator<Session>();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      final bloc = context.read<CheckoutBloc>();
      if (bloc.state is! CheckoutLoading && hasMore) {
        _loadMoreTransactions();
      }
    }
  }

  void _loadTransactions({bool isRefresh = false}) {
    if (isRefresh) {
      setState(() {
        transactions.clear();
        currentOffset = 0;
        hasMore = true;
      });
    }

    context.read<CheckoutBloc>().add(GetCheckoutListEvent(
          userId: session.getIdUser,
          limit: limit,
          offset: currentOffset,
          status: selectedStatus == 'all' ? null : selectedStatus,
        ));
  }

  void _loadMoreTransactions() {
    _loadTransactions();
  }

  Future<void> _refreshTransactions() async {
    _loadTransactions(isRefresh: true);
  }

  void _onStatusFilterChanged(String status) {
    setState(() {
      selectedStatus = status;
    });
    _loadTransactions(isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => locator<CheckoutBloc>()
        ..add(GetCheckoutListEvent(
          userId: session.getIdUser,
          limit: limit,
          offset: currentOffset,
          status: selectedStatus == 'all' ? null : selectedStatus,
        )),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Riwayat Transaksi',
            style: TextStyle(color: white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: Colors.red,
          elevation: 1,
          actions: [
            PopupMenuButton<String>(
              onSelected: _onStatusFilterChanged,
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'all', child: Text('Semua Status')),
                const PopupMenuItem(value: 'pending', child: Text('Pending')),
                const PopupMenuItem(value: 'berhasil', child: Text('Berhasil')),
                const PopupMenuItem(value: 'gagal', child: Text('Gagal')),
                const PopupMenuItem(value: 'expired', child: Text('Expired')),
              ],
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      selectedStatus == 'all'
                          ? 'Semua'
                          : selectedStatus.toUpperCase(),
                      style: const TextStyle(fontSize: 14, color: white),
                    ),
                    const Icon(
                      Icons.arrow_drop_down,
                      color: white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: BlocListener<CheckoutBloc, CheckoutState>(
            listener: (context, state) {
              if (state is CheckoutLoaded) {
                final newTransactions = state.data;
                setState(() {
                  if (currentOffset == 0) {
                    transactions = newTransactions;
                  } else {
                    transactions.addAll(newTransactions);
                  }

                  hasMore = newTransactions.length == limit;
                  currentOffset += newTransactions.length;
                });
              }

              if (state is CheckoutError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.failure.message)),
                );
              }
            },
            child: BlocBuilder<CheckoutBloc, CheckoutState>(
              builder: (context, state) {
                if (state is CheckoutLoading && transactions.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (transactions.isEmpty && state is! CheckoutLoading) {
                  return RefreshIndicator(
                    onRefresh: _refreshTransactions,
                    child: ListView(
                      children: const [
                        SizedBox(height: 200),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.receipt_long,
                                  size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'Belum ada transaksi',
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refreshTransactions,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: transactions.length + (hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == transactions.length) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: state is CheckoutLoading
                                ? const CircularProgressIndicator()
                                : const SizedBox.shrink(),
                          ),
                        );
                      }

                      final transaction = transactions[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            showTransactionDetail(
                                context: context, transaction: transaction);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Order #${transaction.id}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: getStatusColor(
                                                transaction.statusPembayaran)
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            getStatusIcon(
                                                transaction.statusPembayaran),
                                            size: 14,
                                            color: getStatusColor(
                                                transaction.statusPembayaran),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            transaction.statusPembayaran
                                                .toUpperCase(),
                                            style: TextStyle(
                                              color: getStatusColor(
                                                  transaction.statusPembayaran),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today,
                                        size: 14, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      formatDateIndonesia(
                                          transaction.tanggalTransaksi),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.payment,
                                        size: 14, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      getPaymentMethodDisplay(
                                        transaction.metodePembayaran,
                                        transaction.midtransData,
                                      ),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                if (transaction.midtransData?.vaNumber !=
                                    null) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.account_balance,
                                          size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Text(
                                        'VA: ${transaction.midtransData!.vaNumber}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                const Divider(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Total',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      formatIDR(
                                          double.tryParse(transaction.total)),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
        backgroundColor: const Color(0xFFF9F4F8),
      ),
    );
  }
}
