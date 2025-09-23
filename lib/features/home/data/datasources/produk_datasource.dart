import 'package:dio/dio.dart';
import 'package:frontend/cores/services/app_config.dart';
import 'package:frontend/cores/utils/helper.dart';
import 'package:frontend/cores/utils/injection.dart';
import 'package:frontend/cores/utils/session.dart';
import 'package:frontend/features/home/data/models/bookmark_model.dart';
import 'package:frontend/features/home/data/models/cart_model.dart';
import 'package:frontend/features/home/data/models/produk_model.dart';

abstract class SparepartDatasource {
  Future<List<SparepartModel>> getSparepartList();
  Future<CartResponse> addToCart({
    required String sparepartId,
    required int quantity,
  });
  Future<CartResponse> getItemCart();
  Future<CartResponse> removeItemCart({required String sparepartId});
  Future<BookmarkResponseModel> addBookmark({
    required String sparepartId,
  });
  Future<BookmarkResponseModel> getBookmark();
  Future<SparepartResponse> getSparepartByKategori(String namaKategori);
  Future<BookmarkResponseModel> removeBookmarkCart(
      {required String sparepartId});
}

class SparepartDataSourceImpl implements SparepartDatasource {
  final Dio dio;

  SparepartDataSourceImpl({required this.dio});

  @override
  Future<List<SparepartModel>> getSparepartList() async {
    final String url = '${AppConfig.baseURL}sparepart';
    // final session = locator<Session>();
    try {
      final response = await dio.get(
        url,
      );

      final List data = response.data['data'];
      return data.map((e) => SparepartModel.fromJson(e)).toList();
    } on DioException catch (e) {
      logger(e.message ?? e.toString(), label: "Sparepart Datasource Error");
      throw Exception("Failed to load sparepart list");
    }
  }

  @override
  Future<CartResponse> addToCart({
    required String sparepartId,
    required int quantity,
  }) async {
    final String url = '${AppConfig.baseURL}cart';
    final session = locator<Session>();
    try {
      final response = await dio.post(url,
          data: {
            'sparepart_id': sparepartId,
            'quantity': quantity,
          },
          options: Options(headers: {
            'Authorization': 'Bearer ${session.getToken}',
            'Accept': 'application/json',
          }));

      return CartResponse.fromJson(response.data);
    } on DioException catch (e) {
      logger(e.message ?? e.toString(), label: "Add to Cart Error");
      throw Exception("Gagal menambahkan ke keranjang");
    }
  }

  @override
  Future<CartResponse> getItemCart() async {
    final String url = '${AppConfig.baseURL}cart';
    final session = locator<Session>();
    try {
      final response = await dio.get(url,
          options: Options(headers: {
            'Authorization': 'Bearer ${session.getToken}',
            'Accept': 'application/json',
          }));

      return CartResponse.fromJson(response.data);
    } on DioException catch (e) {
      logger(e.message ?? e.toString(), label: "Get Data Cart Error");
      throw Exception("Gagal mendapatkan data keranjang");
    }
  }

  @override
  Future<CartResponse> removeItemCart({required String sparepartId}) async {
    final String url = '${AppConfig.baseURL}cart/remove';
    final session = locator<Session>();
    try {
      final response = await dio.post(url,
          data: {
            'sparepart_id': sparepartId,
          },
          options: Options(headers: {
            'Authorization': 'Bearer ${session.getToken}',
            'Accept': 'application/json',
          }));

      return CartResponse.fromJson(response.data);
    } on DioException catch (e) {
      logger(e.message ?? e.toString(), label: "Remove Data Cart Error");
      throw Exception("Gagal menghapus data keranjang");
    }
  }

  @override
  Future<BookmarkResponseModel> addBookmark(
      {required String sparepartId}) async {
    final String url = '${AppConfig.baseURL}bookmark';
    final session = locator<Session>();
    try {
      final response = await dio.post(url,
          data: {
            'sparepart_id': sparepartId,
          },
          options: Options(headers: {
            'Authorization': 'Bearer ${session.getToken}',
            'Accept': 'application/json',
          }));

      return BookmarkResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      logger(e.message ?? e.toString(), label: "Add Data Bookmark Error");
      throw Exception("Gagal menambah data bookmark");
    }
  }

  @override
  Future<BookmarkResponseModel> getBookmark() async {
    final String url = '${AppConfig.baseURL}bookmark';
    final session = locator<Session>();
    try {
      final response = await dio.get(url,
          options: Options(headers: {
            'Authorization': 'Bearer ${session.getToken}',
            'Accept': 'application/json',
          }));

      return BookmarkResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      logger(e.message ?? e.toString(), label: "Get Data Bookmark Error");
      throw Exception("Gagal mengambil data bookmark");
    }
  }

  @override
  Future<SparepartResponse> getSparepartByKategori(String namaKategori) async {
    final String url = '${AppConfig.baseURL}sparepart/kategori';
    final session = locator<Session>();

    try {
      final response = await dio.post(
        url,
        data: {'nama_kategori': namaKategori},
        options: Options(
          headers: {
            'Authorization': 'Bearer ${session.getToken}',
            'Accept': 'application/json',
          },
        ),
      );

      return SparepartResponse.fromJson(response.data);
    } on DioException catch (e) {
      logger(e.message ?? e.toString(),
          label: "Get Sparepart By Kategori Error");
      throw Exception("Gagal mengambil sparepart berdasarkan kategori");
    }
  }

  @override
  Future<BookmarkResponseModel> removeBookmarkCart(
      {required String sparepartId}) async {
    final String url = '${AppConfig.baseURL}bookmark/remove';
    final session = locator<Session>();

    try {
      final response = await dio.post(url,
          data: {'sparepart_id': sparepartId},
          options: Options(headers: {
            'Authorization': 'Bearer ${session.getToken}',
          }));
      return BookmarkResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      logger(e.message ?? e.toString(), label: "Remove Bookmark Error");
      throw Exception("Gagal menghapus bookmark");
    }
  }
}
