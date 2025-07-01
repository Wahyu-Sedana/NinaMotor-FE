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
