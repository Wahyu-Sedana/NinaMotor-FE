import 'package:dio/dio.dart';
import 'package:frontend/cores/services/app_config.dart';
import 'package:frontend/cores/utils/helper.dart';
import 'package:frontend/features/home/data/models/kategori_model.dart';

abstract class KategoriDatasource {
  Future<List<KategoriModel>> getKategoriList();
}

class KategoriDataSourceImpl implements KategoriDatasource {
  final Dio dio;

  KategoriDataSourceImpl({required this.dio});

  @override
  Future<List<KategoriModel>> getKategoriList() async {
    final String url = '${AppConfig.baseURL}kategori';

    try {
      final response = await dio.get(url);
      final List data = response.data['data'];
      return data.map((e) => KategoriModel.fromJson(e)).toList();
    } on DioException catch (e) {
      logger(e.message ?? e.toString(), label: "Kategori Datasource Error");
      throw Exception("Failed to load kategori list");
    }
  }
}
