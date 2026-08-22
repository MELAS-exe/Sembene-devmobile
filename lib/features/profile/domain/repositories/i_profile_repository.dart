import 'package:dartz/dartz.dart';
import 'package:tera/core/domain/failures/failure.dart';
import 'package:tera/features/profile/domain/entities/user_profile.dart';

abstract class IProfileRepository {
  Future<Either<Failure, UserProfile>> getMyProfile();
  Future<Either<Failure, UserProfile>> updateProfile({
    String? firstName,
    String? lastName,
    String? bio,
  });
}
