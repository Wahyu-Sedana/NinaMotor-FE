import 'package:bloc/bloc.dart';
import 'package:frontend/cores/utils/helper.dart';
import 'package:frontend/features/profile/domain/usecases/profile_usecase.dart';
import 'package:frontend/features/profile/presentations/bloc/event/profile_event.dart';
import 'package:frontend/features/profile/presentations/bloc/state/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileUsecaseImpl profileUsecaseImpl;

  ProfileBloc({required this.profileUsecaseImpl}) : super(ProfileInitial()) {
    on<GetProfileEvent>(_onGetProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onGetProfile(
      GetProfileEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());

    final result = await profileUsecaseImpl.callProfile();

    result.fold(
      (error) => emit(ProfileError(failure: error)),
      (data) {
        logger("hasil profile");
        logger(data.user.noTelp);
        emit(ProfileLoadSuccess(profile: data.user));
      },
    );
  }

  Future<void> _onUpdateProfile(
      UpdateProfileEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());

    final result = await profileUsecaseImpl.callUpdateProfile(
        event.nama, event.alamat, event.noTelp, event.imageProfile ?? "");

    result.fold(
      (error) => emit(ProfileError(failure: error)),
      (data) => emit(ProfileLoadSuccess(profile: data.user)),
    );
  }
}
