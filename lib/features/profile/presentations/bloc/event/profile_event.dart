import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class ProfileEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetProfileEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final String name;
  final String email;

  UpdateProfileEvent({
    required this.name,
    required this.email,
  });

  @override
  List<Object> get props => [name, email];
}

class UploadProfilePhotoEvent extends ProfileEvent {
  final File image;

  UploadProfilePhotoEvent({required this.image});

  @override
  List<Object> get props => [image];
}
