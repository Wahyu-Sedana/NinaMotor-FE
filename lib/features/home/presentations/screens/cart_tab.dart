import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/cores/services/app_config.dart';
import 'package:frontend/features/home/presentations/bloc/event/produk_event.dart';
import 'package:frontend/features/home/presentations/bloc/produk_bloc.dart';
import 'package:frontend/features/home/presentations/bloc/state/produk_state.dart';
import 'package:frontend/features/pembayaran/presentations/screens/pembayaran_screen.dart';

class CartTab extends StatefulWidget {
  const CartTab({super.key});

  @override
  State<CartTab> createState() => _CartTabState();
}

class _CartTabState extends State<CartTab> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedCartIds = {};

  @override
  void initState() {
    super.initState();
    context.read<SparepartBloc>().add(GetItemCartEvent());
  }

  void _onItemChecked(bool? value, String sparepartId) {
    setState(() {
      if (value ?? false) {
        _selectedCartIds.add(sparepartId);
      } else {
        _selectedCartIds.remove(sparepartId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari item...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (_) {
                // Optional: implement local search filter
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<SparepartBloc, SparepartState>(
                builder: (context, state) {
                  switch (state) {
                    case CartLoading():
                      return const Center(child: CircularProgressIndicator());

                    case CartFailure():
                      return const Center(
                          child: Text('Gagal memuat keranjang'));

                    case CartSuccess():
                      final carts = state.data;
                      if (carts.data == null || carts.data!.items.isEmpty) {
                        return const Center(child: Text('Keranjang kosong'));
                      }

                      final allCartItems = carts.data!.items;

                      return Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: allCartItems.length,
                              itemBuilder: (context, index) {
                                final cart = allCartItems[index];
                                return InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => _onItemChecked(
                                    !_selectedCartIds
                                        .contains(cart.sparepartId),
                                    cart.sparepartId,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.05),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Checkbox(
                                          value: _selectedCartIds
                                              .contains(cart.sparepartId),
                                          onChanged: (val) => _onItemChecked(
                                              val, cart.sparepartId),
                                        ),
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.network(
                                            '$baseURLImage${cart.gambar}',
                                            width: 48,
                                            height: 48,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                const Icon(
                                                    Icons.image_not_supported,
                                                    size: 48),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                cart.nama,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w600),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Jumlah: ${cart.quantity}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline,
                                              color: Colors.red),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (_) {
                                                return AlertDialog(
                                                  title: Text(
                                                      'Hapus ${cart.nama}?'),
                                                  content: const Text(
                                                      'Apakah Anda yakin ingin menghapus item ini?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        context
                                                            .read<
                                                                SparepartBloc>()
                                                            .add(RemoveFromCartEvent(
                                                                sparepartId: cart
                                                                    .sparepartId));
                                                        Navigator.pop(context);
                                                      },
                                                      child:
                                                          const Text('Hapus'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context),
                                                      child:
                                                          const Text('Batal'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                top: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total dipilih: ${_selectedCartIds.length}',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                ElevatedButton(
                                  onPressed: _selectedCartIds.isEmpty
                                      ? null
                                      : () {
                                          final selectedItems = allCartItems
                                              .where((item) => _selectedCartIds
                                                  .contains(item.sparepartId))
                                              .toList();

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  CheckoutScreen(
                                                cartItems: selectedItems,
                                                total: carts.data!.total,
                                              ),
                                            ),
                                          );
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                  ),
                                  child: const Text('Checkout'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );

                    default:
                      return const SizedBox();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
