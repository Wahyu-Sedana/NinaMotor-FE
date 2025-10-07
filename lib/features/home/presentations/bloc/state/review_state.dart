import 'package:frontend/cores/errors/failure.dart';
import 'package:frontend/features/home/data/models/review_model.dart';

abstract class ReviewState {}

class ReviewInitial extends ReviewState {}

class ReviewLoading extends ReviewState {}

class ReviewLoaded extends ReviewState {
  final ReviewSummaryModel reviewSummary;

  ReviewLoaded({required this.reviewSummary});
}

class ReviewSubmitting extends ReviewState {}

class ReviewSubmitSuccess extends ReviewState {
  final String message;

  ReviewSubmitSuccess({required this.message});
}

class ReviewDeleting extends ReviewState {}

class ReviewDeleteSuccess extends ReviewState {
  final String message;

  ReviewDeleteSuccess({required this.message});
}

class ReviewFailure extends ReviewState {
  final Failure failure;

  ReviewFailure({required this.failure});
}
