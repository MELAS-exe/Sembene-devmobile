part of 'edit_profile_cubit.dart';

sealed class EditProfileState {
  const EditProfileState();
}

class EditProfileInitial extends EditProfileState {
  const EditProfileInitial();
}

class EditProfileSubmitting extends EditProfileState {
  const EditProfileSubmitting();
}

class EditProfileSuccess extends EditProfileState {
  const EditProfileSuccess(this.profile);
  final UserProfile profile;
}

class EditProfileError extends EditProfileState {
  const EditProfileError(this.message);
  final String message;
}
