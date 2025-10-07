import 'package:dio/dio.dart';

class RajaOngkirService {
  static const String _baseUrl = 'https://rajaongkir.komerce.id/api/v1';
  static const String _apiKey = 'GJfqkufwe2692a025cb926e2EqUPiKoT';

  final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    headers: {'key': _apiKey},
  ));

  Future<List<Map<String, dynamic>>> getProvinces() async {
    final response = await _dio.get('/destination/province');
    if (response.data['meta']['code'] == 200) {
      final results = response.data['data'] as List;
      return results.map((item) {
        return {
          'province_id': item['id'],
          'province': item['name'],
        };
      }).toList();
    }
    throw Exception('Failed to load provinces');
  }

  Future<List<Map<String, dynamic>>> getDistrict(int cityId) async {
    final response = await _dio.get('/destination/district/$cityId');
    if (response.data['meta']['code'] == 200) {
      final results = response.data['data'] as List;
      return results.map((item) {
        return {
          'district_id': item['id'],
          'district_name': item['name'],
        };
      }).toList();
    }
    throw Exception('Failed to load provinces');
  }

  Future<List<Map<String, dynamic>>> getCities(int provinceId) async {
    try {
      final response = await _dio.get('/destination/city/$provinceId');
      if (response.data['meta']['code'] == 200) {
        final results = response.data['data'] as List;
        return results.map((item) {
          return {
            'city_id': item['id'],
            'city_name': item['name'],
          };
        }).toList();
      }
      throw Exception('Failed to load cities');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getShippingCost({
    required int originDistrictId,
    required int destinationDistrictId,
    required int weight,
  }) async {
    try {
      final response = await _dio.post(
        '/calculate/district/domestic-cost',
        options: Options(
          headers: {
            'key': _apiKey,
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
        data: {
          'origin': originDistrictId,
          'destination': destinationDistrictId,
          'weight': weight,
          'courier': 'jne',
          'price': 'lowest',
        },
      );

      if (response.data['meta']['code'] == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((e) => e as Map<String, dynamic>).toList();
      }

      throw Exception(
          'Failed to get shipping cost: ${response.data['meta']['message']}');
    } catch (e) {
      rethrow;
    }
  }
}
