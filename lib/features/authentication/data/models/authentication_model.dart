class AuthenticationModelLogin {
  final String email;
  final String password;
  final String token;

  AuthenticationModelLogin(
      {required this.token, required this.email, required this.password});

  Map<String, String> toJson() {
    return {'email': email, 'password': password};
  }

  factory AuthenticationModelLogin.fromJson(Map<String, dynamic> json) {
    return AuthenticationModelLogin(
        token: json['token'] ?? "",
        email: json['email'] ?? "",
        password: json['password'] ?? "");
  }
}

class AuthenticationModelLogout {
  final String message;
  final int status;

  AuthenticationModelLogout({required this.message, required this.status});

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
    };
  }

  factory AuthenticationModelLogout.fromJson(Map<String, dynamic> json) {
    return AuthenticationModelLogout(
      message: json['message'] ?? "",
      status: json['status'] ?? 0,
    );
  }
}
