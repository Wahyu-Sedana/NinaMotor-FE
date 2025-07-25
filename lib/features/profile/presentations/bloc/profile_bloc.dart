import 'package:bloc/bloc.dart';
import 'package:frontend/features/profile/domain/usecases/profile_usecase.dart';
import 'package:frontend/features/profile/presentations/bloc/event/profile_event.dart';
import 'package:frontend/features/profile/presentations/bloc/state/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileUsecaseImpl profileUsecaseImpl;

  ProfileBloc({required this.profileUsecaseImpl}) : super(ProfileInitial()) {
    on<GetProfileEvent>(_onGetProfile);
    // on<UpdateProfileEvent>(_onUpdateProfile);
    // on<UploadProfilePhotoEvent>(_onUploadPhoto);
  }

  Future<void> _onGetProfile(
      GetProfileEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());

    final result = await profileUsecaseImpl.callProfile();

    result.fold(
      (error) => emit(ProfileError(failure: error)),
      (data) => emit(ProfileLoadSuccess(profile: data.user)),
    );
  }

  // Future<void> _onUpdateProfile(
  //     UpdateProfileEvent event, Emitter<ProfileState> emit) async {
  //   emit(ProfileLoading());

  //   final result =
  //       await profileUsecaseImpl.callUpdateProfile(event.name, event.email);

  //   result.fold(
  //     (error) => emit(ProfileError(failure: error)),
  //     (data) => emit(ProfileUpdateSuccess(message: data.message)),
  //   );
  // }

  // Future<void> _onUploadPhoto(
  //     UploadProfilePhotoEvent event, Emitter<ProfileState> emit) async {
  //   emit(ProfileLoading());

  //   final result = await profileUsecaseImpl.callUploadProfilePhoto(event.image);

  //   result.fold(
  //     (error) => emit(ProfileError(failure: error)),
  //     (data) => emit(ProfileUploadPhotoSuccess(imageUrl: data.imageUrl)),
  //   );
  // }
}
