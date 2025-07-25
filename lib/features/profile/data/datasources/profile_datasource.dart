import 'package:dio/dio.dart';
import 'package:frontend/cores/services/app_config.dart';
import 'package:frontend/cores/utils/injection.dart';
import 'package:frontend/cores/utils/session.dart';
import 'package:frontend/features/profile/data/models/profile_model.dart';

abstract class ProfileDatasource {
  Future<ProfileResponse> getProfile();
}

class ProfileDatasourceImpl implements ProfileDatasource {
  final Dio dio;

  ProfileDatasourceImpl({required this.dio});

  @override
  Future<ProfileResponse> getProfile() async {
    final path = '${baseURL}profile';
    final session = locator<Session>();
    try {
      final response = await dio.post(path,
          options: Options(
            headers: {
              'Authorization': 'Bearer ${session.getToken}',
            },
          ));
      return ProfileResponse.fromJson(response.data);
    } catch (e) {
      throw e.toString();
    }
  }
}
