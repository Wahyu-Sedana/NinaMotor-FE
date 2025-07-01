class AuthenticationModelLogin {
  final String email;
  final String password;

  AuthenticationModelLogin({required this.email, required this.password});

  Map<String, String> toJson() {
    return {'email': email, 'password': password};
  }

  factory AuthenticationModelLogin.fromJson(Map<String, String> json) {
    return AuthenticationModelLogin(
        email: json['email'] ?? "", password: json['password'] ?? "");
  }
}
