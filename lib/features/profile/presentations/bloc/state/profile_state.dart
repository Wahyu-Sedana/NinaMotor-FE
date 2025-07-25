import 'package:equatable/equatable.dart';
import 'package:frontend/cores/errors/failure.dart';
import 'package:frontend/features/profile/data/models/profile_model.dart';

abstract class ProfileState extends Equatable {
  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoadSuccess extends ProfileState {
  final ProfileModel profile;
  ProfileLoadSuccess({required this.profile});

  @override
  List<Object> get props => [profile];
}

class ProfileUpdateSuccess extends ProfileState {
  final String message;
  ProfileUpdateSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class ProfileUploadPhotoSuccess extends ProfileState {
  final String imageUrl;
  ProfileUploadPhotoSuccess({required this.imageUrl});

  @override
  List<Object> get props => [imageUrl];
}

class ProfileError extends ProfileState {
  final Failure failure;
  ProfileError({required this.failure});

  @override
  List<Object> get props => [failure];
}
