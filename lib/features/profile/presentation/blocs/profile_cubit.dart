import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:tera/core/domain/failures/failure.dart';
import 'package:tera/core/storages/local_storages.dart';
import 'package:tera/features/profile/domain/entities/user_profile.dart';
import 'package:tera/features/profile/domain/repositories/i_profile_repository.dart';

part 'profile_state.dart';

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._repo, this._storage) : super(const ProfileInitial());

  final IProfileRepository _repo;
  final LocalStorage _storage;

  Future<void> loadProfile() async {
    emit(const ProfileLoading());
    final result = await _repo.getMyProfile();
    final phone = await _storage.getPhoneNumber();
    result.fold(
      (f) => emit(ProfileError(
          f is LocalFailure ? f.message : (f as ServerFailure).message)),
      (profile) => emit(ProfileLoaded(profile, phone: phone)),
    );
  }
}
