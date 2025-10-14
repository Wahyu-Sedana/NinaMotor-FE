import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class ProfileEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetProfileEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final String nama;
  final String noTelp;
  final String? imageProfile;

  UpdateProfileEvent({
    required this.nama,
    required this.noTelp,
    required this.imageProfile,
  });

  @override
  List<Object> get props => [nama, noTelp];
}

class UploadProfilePhotoEvent extends ProfileEvent {
  final File image;

  UploadProfilePhotoEvent({required this.image});

  @override
  List<Object> get props => [image];
}
