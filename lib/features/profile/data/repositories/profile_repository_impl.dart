import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:tera/core/domain/failures/failure.dart';
import 'package:tera/core/network/dio_client.dart';
import 'package:tera/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:tera/features/profile/domain/entities/user_profile.dart';
import 'package:tera/features/profile/domain/repositories/i_profile_repository.dart';

@LazySingleton(as: IProfileRepository)
class ProfileRepositoryImpl implements IProfileRepository {
  ProfileRepositoryImpl(this._remote);
  final IProfileRemoteDataSource _remote;

  @override
  Future<Either<Failure, UserProfile>> getMyProfile() async {
    try {
      final model = await _remote.getMyProfile();
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(dioToFailure(e));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateProfile({
    String? firstName,
    String? lastName,
    String? bio,
  }) async {
    try {
      final model = await _remote.updateProfile(
        firstName: firstName,
        lastName: lastName,
        bio: bio,
      );
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(dioToFailure(e));
    }
  }
}
