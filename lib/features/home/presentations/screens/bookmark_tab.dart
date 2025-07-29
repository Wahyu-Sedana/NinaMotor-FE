import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/home/presentations/bloc/event/produk_event.dart';
import 'package:frontend/features/home/presentations/bloc/produk_bloc.dart';
import 'package:frontend/features/home/presentations/bloc/state/produk_state.dart';

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
        body: SafeArea(
            child: Column(
          children: [
            // Search Bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search bookmarked items...',
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
            ),

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
                      return const Center(child: Text('No bookmarks found.'));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: bookmarks.length,
                      itemBuilder: (context, index) {
                        final bookmark = bookmarks[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          child: ListTile(
                            leading: Image.network(
                              'http://127.0.0.1:8000/storage/${bookmark.sparepart.gambarProduk}',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.image_not_supported),
                            ),
                            title: Text(bookmark.sparepart.nama),
                            subtitle: Text('Kode: ${bookmark.sparepartId}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () {
                                // context.read<SparepartBloc>().add(
                                //       RemoveFromBookmarkEvent(
                                //         sparepartId: bookmark.sparepartId,
                                //       ),
                                //     );
                              },
                            ),
                          ),
                        );
                      },
                    );
                  }

                  if (state is BookmarkFailure) {
                    return Center(
                        child: Text('Failed: ${state.failure.message}'));
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        )));
  }
}
