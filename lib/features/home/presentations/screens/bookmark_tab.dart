import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/cores/services/app_config.dart';
import 'package:frontend/features/home/presentations/bloc/event/produk_event.dart';
import 'package:frontend/features/home/presentations/bloc/produk_bloc.dart';
import 'package:frontend/features/home/presentations/bloc/state/produk_state.dart';
import 'package:frontend/cores/utils/colors.dart';

class BookmarkTab extends StatefulWidget {
  const BookmarkTab({super.key});

  @override
  State<BookmarkTab> createState() => _BookmarkTabState();
}

class _BookmarkTabState extends State<BookmarkTab> {
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<SparepartBloc>().add(GetItemBookmarkEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookmark')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Cari item bookmark...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // List Bookmark
            Expanded(
              child: BlocBuilder<SparepartBloc, SparepartState>(
                builder: (context, state) {
                  if (state is BookmarkLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is GetBookmarkListSuccess) {
                    final bookmarks = state.bookmarks.where((item) {
                      final name = item.sparepart.nama.toLowerCase();
                      return name.contains(searchQuery.toLowerCase());
                    }).toList();

                    if (bookmarks.isEmpty) {
                      return const Center(child: Text('Bookmark kosong.'));
                    }

                    return ListView.separated(
                      itemCount: bookmarks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final bookmark = bookmarks[index];
                        final imageUrl =
                            '$baseURLImage${bookmark.sparepart.gambarProduk}';

                        return InkWell(
                          onTap: () {
                            // Optional: tambahkan navigasi ke detail jika perlu
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
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
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  // Gambar
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      imageUrl,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                          Icons.image_not_supported,
                                          size: 60),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          bookmark.sparepart.nama,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Kode: ${bookmark.sparepartId}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Hapus Bookmark
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: redColor),
                                    onPressed: () {
                                      // Tambahkan logika penghapusan
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }

                  if (state is BookmarkFailure) {
                    return Center(
                        child: Text('Gagal memuat: ${state.failure.message}'));
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
