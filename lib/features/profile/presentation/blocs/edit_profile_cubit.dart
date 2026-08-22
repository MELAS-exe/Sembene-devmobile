import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:tera/core/domain/failures/failure.dart';
import 'package:tera/features/profile/domain/entities/user_profile.dart';
import 'package:tera/features/profile/domain/repositories/i_profile_repository.dart';

part 'edit_profile_state.dart';

@injectable
class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit(this._repo) : super(const EditProfileInitial());

  final IProfileRepository _repo;

  Future<void> submit({
    required String firstName,
    required String lastName,
    String? bio,
  }) async {
    emit(const EditProfileSubmitting());
    final result = await _repo.updateProfile(
      firstName: firstName,
      lastName: lastName,
      bio: (bio?.isNotEmpty ?? false) ? bio : null,
    );
    result.fold(
      (f) => emit(EditProfileError(
          f is LocalFailure ? f.message : (f as ServerFailure).message)),
      (profile) => emit(EditProfileSuccess(profile)),
    );
  }
}
