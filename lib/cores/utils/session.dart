import 'package:frontend/cores/utils/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class Session {
  set setToken(String token);
  set setUsername(String username);
  set setEmail(String email);
  set setIdUser(String userId);
  String get getToken;
  String get getUsername;
  String get getEmail;

  String get getIdUser;

  Future<void> clearSession();
}

class SessionImpl implements Session {
  final SharedPreferences pref;

  SessionImpl({required this.pref});

  @override
  set setToken(String token) {
    pref.setString(TOKEN, token);
  }

  @override
  set setUsername(String username) {
    pref.setString(USERNAME, username);
  }

  @override
  set setEmail(String email) {
    pref.setString(EMAIL, email);
  }

  @override
  set setIdUser(String userId) {
    pref.setString("USER_ID", userId);
  }

  @override
  String get getToken => pref.getString(TOKEN) ?? "";

  @override
  String get getUsername => pref.getString(USERNAME) ?? "";

  @override
  String get getEmail => pref.getString(EMAIL) ?? "";

  @override
  String get getIdUser => pref.getString("USER_ID") ?? "";

  @override
  Future<void> clearSession() async {
    await pref.clear();
  }
}
