import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/home/presentations/bloc/event/review_event.dart';
import 'package:frontend/features/home/presentations/bloc/review_bloc.dart';
import 'package:frontend/features/home/presentations/bloc/state/review_state.dart';
import 'package:frontend/features/home/presentations/widgets/review_card_widget.dart';

class ReviewsScreen extends StatefulWidget {
  final String sparepartId;
  final String sparepartName;

  const ReviewsScreen({
    super.key,
    required this.sparepartId,
    required this.sparepartName,
  });

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  void _loadReviews() {
    context.read<ReviewBloc>().add(
          GetReviewsEvent(sparepartId: widget.sparepartId),
        );
  }

  void _showWriteReviewDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WriteReviewDialog(
        sparepartId: widget.sparepartId,
        sparepartName: widget.sparepartName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Ulasan Produk',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: BlocConsumer<ReviewBloc, ReviewState>(
        listener: (context, state) {
          if (state is ReviewSubmitSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is ReviewFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.failure.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ReviewLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ReviewLoaded) {
            final summary = state.reviewSummary;

            return RefreshIndicator(
              onRefresh: () async => _loadReviews(),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: ReviewSummaryHeader(
                      sparepartName: summary.sparepart,
                      averageRating: summary.averageRating,
                      totalReviews: summary.totalReviews,
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: summary.reviews.isEmpty
                        ? SliverFillRemaining(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.rate_review_outlined,
                                    size: 80,
                                    color: Colors.grey[300],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Belum ada ulasan',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final review = summary.reviews[index];
                                return ReviewCard(
                                  review: review,
                                  onDelete: () {
                                    _showDeleteConfirmation(review.id);
                                  },
                                );
                              },
                              childCount: summary.reviews.length,
                            ),
                          ),
                  ),
                ],
              ),
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text('Gagal memuat ulasan'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadReviews,
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showWriteReviewDialog,
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.edit_rounded, color: Colors.white),
        label: const Text(
          'Tulis Ulasan',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(int reviewId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Ulasan'),
        content: const Text('Apakah Anda yakin ingin menghapus ulasan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              context.read<ReviewBloc>().add(
                    DeleteReviewEvent(reviewId: reviewId),
                  );
              Navigator.pop(context);
              _loadReviews();
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
