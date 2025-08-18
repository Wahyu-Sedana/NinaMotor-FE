import 'package:frontend/features/home/data/models/produk_model.dart';

class BookmarkResponseModel {
  final int status;
  final String message;
  final List<BookmarkModel> data;

  BookmarkResponseModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory BookmarkResponseModel.fromJson(Map<String, dynamic> json) {
    List<BookmarkModel> _data = [];

    if (json['data'] is List) {
      _data = (json['data'] as List)
          .map((data) => BookmarkModel.fromJson(data ?? {}))
          .toList();
    }

    return BookmarkResponseModel(
        status: json['status'] ?? 0,
        message: json['message'] ?? '',
        data: _data);
  }
}

class BookmarkModel {
  final int id;
  final String userId;
  final String sparepartId;
  final String createdAt;
  final String updatedAt;
  final SparepartModel sparepart;

  BookmarkModel({
    required this.id,
    required this.userId,
    required this.sparepartId,
    required this.createdAt,
    required this.updatedAt,
    required this.sparepart,
  });

  factory BookmarkModel.fromJson(Map<String, dynamic> json) {
    return BookmarkModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? '',
      sparepartId: json['sparepart_id'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      sparepart: SparepartModel.fromJson(json['sparepart'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'sparepart_id': sparepartId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'sparepart': sparepart.toJson(),
    };
  }
}
