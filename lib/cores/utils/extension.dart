import 'package:frontend/cores/utils/enum.dart';

extension JenisMotorExtension on JenisMotor {
  String get label {
    switch (this) {
      case JenisMotor.manual:
        return "Manual";
      case JenisMotor.matic:
        return "Matic";
    }
  }
}
