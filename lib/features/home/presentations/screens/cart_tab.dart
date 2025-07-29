import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/home/presentations/bloc/event/produk_event.dart';
import 'package:frontend/features/home/presentations/bloc/produk_bloc.dart';
import 'package:frontend/features/home/presentations/bloc/state/produk_state.dart';

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
                    return const Center(child: Text('Gagal memuat keranjang'));

                  case CartSuccess():
                    final carts = state.data;
                    if (carts.data == null || carts.data!.items.isEmpty) {
                      return const Center(child: Text('Keranjang kosong'));
                    }
                    return ListView.builder(
                      itemCount: carts.data!.items.length,
                      itemBuilder: (context, index) {
                        final cart = carts.data!.items[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Checkbox(
                                  value: _selectedCartIds
                                      .contains(cart.sparepartId),
                                  onChanged: (val) =>
                                      _onItemChecked(val, cart.sparepartId),
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    'http://127.0.0.1:8000/storage/${cart.gambar}',
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.image_not_supported),
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
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 4),
                                      Text('Jumlah: ${cart.quantity}'),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red),
                                  onPressed: () {
                                    context.read<SparepartBloc>().add(
                                          RemoveFromCartEvent(
                                              sparepartId: cart.sparepartId),
                                        );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );

                  default:
                    return const SizedBox();
                }
              }),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: _selectedCartIds.isEmpty
                        ? null
                        : () {
                            debugPrint('Checkout items: $_selectedCartIds');
                            // TODO: Checkout logic
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
        ),
      ),
    );
  }
}
