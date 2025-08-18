import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/cores/services/app_config.dart';
import 'package:frontend/cores/utils/colors.dart';
import 'package:frontend/cores/utils/helper.dart';
import 'package:frontend/features/home/data/models/produk_model.dart';
import 'package:frontend/features/home/presentations/bloc/event/produk_event.dart';
import 'package:frontend/features/home/presentations/bloc/produk_bloc.dart';
import 'package:frontend/features/home/presentations/bloc/state/produk_state.dart';

class SparepartDetailScreen extends StatefulWidget {
  final SparepartModel sparepart;

  const SparepartDetailScreen({super.key, required this.sparepart});

  @override
  State<SparepartDetailScreen> createState() => _SparepartDetailScreenState();
}

class _SparepartDetailScreenState extends State<SparepartDetailScreen> {
  int quantity = 1;
  bool isBookmarked = false;
  bool _isLoading = false;
  double totalHarga = 0.0;

  @override
  void initState() {
    super.initState();
    totalHarga = double.parse(widget.sparepart.hargaJual) * quantity;
    context.read<SparepartBloc>().add(GetItemBookmarkEvent());
  }

  @override
  Widget build(BuildContext context) {
    final sparepart = widget.sparepart;

    return BlocListener<SparepartBloc, SparepartState>(
        listener: (context, state) {
          if (state is CartLoading) {
            setState(() {
              _isLoading = true;
            });
          } else if (state is CartSuccess) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("Berhasil ditambahkan ke keranjang")),
            );
          } else if (state is CartFailure) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Gagal: ${state.failure.message}")),
            );
          } else if (state is BookmarkSuccess) {
            context.read<SparepartBloc>().add(GetItemBookmarkEvent());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Bookmark berhasil diupdate')),
            );
          } else if (state is GetBookmarkListSuccess) {
            final bookmarkedIds =
                state.bookmarks.map((b) => b.sparepartId).toList();
            setState(() {
              isBookmarked =
                  bookmarkedIds.contains(widget.sparepart.kodeSparepart);
            });
          } else if (state is BookmarkFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text('Gagal update bookmark: ${state.failure.message}')),
            );
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF4F6FA),
          appBar: AppBar(
            backgroundColor: Colors.red,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text("Detail Produk",
                style: TextStyle(color: Colors.white)),
            actions: [
              IconButton(
                icon: Icon(
                  isBookmarked ? Icons.favorite : Icons.favorite_border,
                  color: isBookmarked ? Colors.pink : Colors.white,
                ),
                onPressed: () {
                  if (!isBookmarked) {
                    context.read<SparepartBloc>().add(
                          AddToItemBookmarkEvent(
                              sparepartId: sparepart.kodeSparepart),
                        );
                  } else {
                    context.read<SparepartBloc>().add(
                          RemoveFromBookmarkEvent(
                              sparepartId: sparepart.kodeSparepart),
                        );
                  }
                },
              )
            ],
          ),
          body: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.network(
                        '$baseURLImage${sparepart.gambarProduk}',
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sparepart.nama,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.orange, size: 18),
                              const SizedBox(width: 4),
                              Text("4.7",
                                  style: TextStyle(color: Colors.grey[700])),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Crafted with high quality and ergonomic design, ready to be installed in your vehicle.",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Stok: ${widget.sparepart.stok}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Text("Jumlah: "),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () {
                                  if (quantity > 1) {
                                    setState(() {
                                      quantity--;
                                      totalHarga =
                                          double.parse(sparepart.hargaJual) *
                                              quantity;
                                    });
                                  }
                                },
                              ),
                              Text('$quantity'),
                              IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () {
                                    if (quantity < widget.sparepart.stok) {
                                      setState(() {
                                        quantity++;
                                        totalHarga =
                                            double.parse(sparepart.hargaJual) *
                                                quantity;
                                      });
                                    }
                                  }),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      )
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 30, right: 20, left: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formatIDR(totalHarga),
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  context.read<SparepartBloc>().add(
                                        AddToCartEvent(
                                          sparepartId: sparepart.kodeSparepart,
                                          quantity: quantity,
                                        ),
                                      );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.shopping_cart_checkout,
                                  color: white,
                                ),
                              )
                      ],
                    ),
                  ))
            ],
          ),
        ));
  }
}
