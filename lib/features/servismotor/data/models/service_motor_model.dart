import 'package:frontend/cores/utils/enum.dart';

class ServisMotorModel {
  final int id;
  final String userId;
  final String noKendaraan;
  final JenisMotor jenisMotor;
  final String keluhan;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ServisMotorModel({
    required this.id,
    required this.userId,
    required this.noKendaraan,
    required this.jenisMotor,
    required this.keluhan,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory ServisMotorModel.fromJson(Map<String, dynamic> json) {
    return ServisMotorModel(
      id: json['id'],
      userId: json['user_id'],
      noKendaraan: json['no_kendaraan'],
      jenisMotor: JenisMotor.values.firstWhere(
        (e) => e.name == json['jenis_motor'],
        orElse: () => JenisMotor.manual,
      ),
      keluhan: json['keluhan'],
      status: json['status'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'no_kendaraan': noKendaraan,
      'jenis_motor': jenisMotor,
      'keluhan': keluhan,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class ServisMotorResponse {
  final int status;
  final String? message;
  final List<ServisMotorModel>? data;

  ServisMotorResponse({
    required this.status,
    this.message,
    this.data,
  });

  factory ServisMotorResponse.fromJson(Map<String, dynamic> json) {
    return ServisMotorResponse(
      status: json['status'],
      message: json['message'],
      data: json['data'] is List
          ? (json['data'] as List)
              .map((item) => ServisMotorModel.fromJson(item))
              .toList()
          : json['data'] != null
              ? [ServisMotorModel.fromJson(json['data'])]
              : null,
    );
  }
}
