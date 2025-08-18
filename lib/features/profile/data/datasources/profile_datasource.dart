import 'package:dio/dio.dart';
import 'package:frontend/cores/services/app_config.dart';
import 'package:frontend/cores/utils/injection.dart';
import 'package:frontend/cores/utils/session.dart';
import 'package:frontend/features/profile/data/models/profile_model.dart';

abstract class ProfileDatasource {
  Future<ProfileResponse> getProfile();
  Future<ProfileResponse> updateProfile(
      String nama, String alamat, String noTelp, String imageProfile);
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

  @override
  Future<ProfileResponse> updateProfile(
      String nama, String alamat, String noTelp, String imageProfile) async {
    final path = '${baseURL}profile/update';
    final session = locator<Session>();
    try {
      final formData = FormData.fromMap({
        "nama": nama,
        "alamat": alamat,
        "no_telp": noTelp,
        if (imageProfile.isNotEmpty)
          "profile": await MultipartFile.fromFile(
            imageProfile,
            filename: imageProfile.split('/').last,
          ),
      });

      final response = await dio.post(path,
          data: formData,
          options: Options(
            headers: {
              'Authorization': 'Bearer ${session.getToken}',
              'Content-Type': 'multipart/form-data',
            },
          ));
      return ProfileResponse.fromJson(response.data);
    } catch (e) {
      throw e.toString();
    }
  }
}
