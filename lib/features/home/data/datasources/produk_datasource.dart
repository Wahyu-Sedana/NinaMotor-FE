import 'package:dio/dio.dart';
import 'package:frontend/cores/services/app_config.dart';
import 'package:frontend/cores/utils/helper.dart';
import 'package:frontend/features/home/data/models/produk_model.dart';

abstract class SparepartDatasource {
  Future<List<SparepartModel>> getSparepartList();
}

class SparepartDataSourceImpl implements SparepartDatasource {
  final Dio dio;

  SparepartDataSourceImpl({required this.dio});

  @override
  Future<List<SparepartModel>> getSparepartList() async {
    final String url = '${baseURL}sparepart';

    try {
      final response = await dio.get(url);

      final List data = response.data['data'];
      return data.map((e) => SparepartModel.fromJson(e)).toList();
    } on DioException catch (e) {
      logger(e.message ?? e.toString(), label: "Sparepart Datasource Error");
      throw Exception("Failed to load sparepart list");
    }
  }
}
