class ProfileResponse {
  final int status;
  final String message;
  final ProfileModel user;

  ProfileResponse({
    required this.status,
    required this.message,
    required this.user,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      status: json['status'],
      message: json['message'],
      user: ProfileModel.fromJson(json['user']),
    );
  }
}

class ProfileModel {
  final String id;
  final String nama;
  final String email;
  final String? emailVerifiedAt;
  final String role;
  final String? alamat;
  final String? noTelp;
  final String? profile;
  final String? createdAt;
  final String? updatedAt;

  ProfileModel({
    required this.id,
    required this.nama,
    required this.email,
    required this.role,
    this.emailVerifiedAt,
    this.alamat,
    this.noTelp,
    this.profile,
    this.createdAt,
    this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? '',
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
      emailVerifiedAt: json['email_verified_at'],
      role: json['role'] ?? '',
      alamat: json['alamat'] ?? '',
      noTelp: json['noTelo'] ?? '',
      profile: json['profile'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'role': role,
      'alamat': alamat,
      'no_telp': noTelp,
      'profile': profile,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
