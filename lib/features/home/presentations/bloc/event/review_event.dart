abstract class ReviewEvent {}

class GetReviewsEvent extends ReviewEvent {
  final String sparepartId;

  GetReviewsEvent({required this.sparepartId});
}

class SubmitReviewEvent extends ReviewEvent {
  final String sparepartId;
  final int rating;
  final String? komentar;

  SubmitReviewEvent({
    required this.sparepartId,
    required this.rating,
    this.komentar,
  });
}

class DeleteReviewEvent extends ReviewEvent {
  final int reviewId;

  DeleteReviewEvent({required this.reviewId});
}
