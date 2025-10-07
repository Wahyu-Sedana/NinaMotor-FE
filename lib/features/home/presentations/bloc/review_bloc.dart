import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/home/domain/usecases/review_usecase.dart';
import 'package:frontend/features/home/presentations/bloc/event/review_event.dart';
import 'package:frontend/features/home/presentations/bloc/state/review_state.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final ReviewUsecaseImpl reviewUsecaseImpl;

  ReviewBloc({
    required this.reviewUsecaseImpl,
  }) : super(ReviewInitial()) {
    on<GetReviewsEvent>(_onGetReviews);
    on<SubmitReviewEvent>(_onSubmitReview);
    on<DeleteReviewEvent>(_onDeleteReview);
  }

  Future<void> _onGetReviews(
    GetReviewsEvent event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewLoading());

    final result = await reviewUsecaseImpl.getReviews(event.sparepartId);

    result.fold(
      (failure) => emit(ReviewFailure(failure: failure)),
      (reviewSummary) => emit(ReviewLoaded(reviewSummary: reviewSummary)),
    );
  }

  Future<void> _onSubmitReview(
    SubmitReviewEvent event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewSubmitting());

    final result = await reviewUsecaseImpl.submitReview(
      sparepartId: event.sparepartId,
      rating: event.rating,
      komentar: event.komentar,
    );

    result.fold(
      (failure) => emit(ReviewFailure(failure: failure)),
      (message) {
        emit(ReviewSubmitSuccess(message: message));
        add(GetReviewsEvent(sparepartId: event.sparepartId));
      },
    );
  }

  Future<void> _onDeleteReview(
    DeleteReviewEvent event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewDeleting());

    final result = await reviewUsecaseImpl.deleteReview(event.reviewId);

    result.fold(
      (failure) => emit(ReviewFailure(failure: failure)),
      (message) => emit(ReviewDeleteSuccess(message: message)),
    );
  }
}
