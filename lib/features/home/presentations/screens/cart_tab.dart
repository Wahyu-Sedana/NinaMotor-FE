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
            // 🔍 Search Bar
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

            // 🛒 Daftar Cart
            Expanded(
              child: BlocBuilder<SparepartBloc, SparepartState>(
                builder: (context, state) {
                  if (state is CartLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is CartFailure) {
                    return Center(child: Text('Gagal memuat keranjang'));
                  }

                  if (state is CartSuccess) {
                    final carts = state.data;

                    if (carts.data == null) {
                      return const Center(child: Text('Keranjang kosong'));
                    }

                    return ListView.builder(
                      itemCount: carts.data!.items.length,
                      itemBuilder: (context, index) {
                        final cart = carts.data!.items[index];
                        return CheckboxListTile(
                          value: _selectedCartIds.contains(cart.sparepartId),
                          onChanged: (val) =>
                              _onItemChecked(val, cart.sparepartId),
                          title: Text(cart.nama),
                          subtitle: Text('Jumlah: ${cart.quantity}'),
                          secondary: Image.network(
                            'http://127.0.0.1:8000/storage/${cart.gambar}',
                            width: 50,
                            height: 50,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.image_not_supported),
                          ),
                        );
                      },
                    );
                  }

                  return const SizedBox();
                },
              ),
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
                            debugPrint('Selected cart IDs: $_selectedCartIds');
                            // Navigasi atau aksi checkout di sini
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
