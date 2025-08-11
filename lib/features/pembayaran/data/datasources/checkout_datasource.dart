import 'package:dio/dio.dart';
import 'package:frontend/cores/services/app_config.dart';
import 'package:frontend/cores/utils/injection.dart';
import 'package:frontend/cores/utils/session.dart';
import 'package:frontend/features/pembayaran/data/models/checkout_model.dart';

abstract class CheckoutDatasource {
  Future<List<Transaction>> getTransactions({
    required String userId,
    required int limit,
    required int offset,
    String? status,
  });
}

class CheckoutDatasourceImpl implements CheckoutDatasource {
  final Dio dio;

  CheckoutDatasourceImpl({required this.dio});

  @override
  Future<List<Transaction>> getTransactions({
    required String userId,
    required int limit,
    required int offset,
    String? status,
  }) async {
    final session = locator<Session>();
    try {
      final queryParams = {
        'user_id': userId,
        'limit': limit,
        'offset': offset,
        if (status != null && status != 'all') 'status': status,
      };

      final response = await dio.get(
        '${baseURL}transaksi/list',
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${session.getToken}',
            'Accept': 'application/json',
          },
        ),
      );

      final json = response.data;

      if (json['success'] == true) {
        final List<dynamic> transactionList = json['data']['transactions'];
        final List<Transaction> transactions =
            transactionList.map((item) => Transaction.fromJson(item)).toList();
        return transactions;
      } else {
        throw Exception(json['message'] ?? 'Failed to load transactions');
      }
    } catch (e) {
      rethrow;
    }
  }
}
