import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:tera/features/profile/data/models/user_profile_model.dart';

abstract class IProfileRemoteDataSource {
  Future<UserProfileModel> getMyProfile();
  Future<UserProfileModel> updateProfile({
    String? firstName,
    String? lastName,
    String? bio,
  });
}

@LazySingleton(as: IProfileRemoteDataSource)
class ProfileRemoteDataSourceImpl implements IProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<UserProfileModel> getMyProfile() async {
    final response = await _dio.get<Map<String, dynamic>>('/api/profile/me');
    return UserProfileModel.fromJson(response.data!);
  }

  @override
  Future<UserProfileModel> updateProfile({
    String? firstName,
    String? lastName,
    String? bio,
  }) async {
    final body = <String, dynamic>{
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (bio != null) 'bio': bio,
    };
    final response =
        await _dio.patch<Map<String, dynamic>>('/api/profile/me', data: body);
    return UserProfileModel.fromJson(response.data!);
  }
}
