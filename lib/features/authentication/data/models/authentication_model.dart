class AuthenticationModel {
  final int status;
  final String message;
  final User user;
  final String token;

  AuthenticationModel(
      {required this.token,
      required this.status,
      required this.message,
      required this.user});

  Map<String, dynamic> toJson() {
    return {'token': token, 'status': status, 'message': message, 'user': user};
  }

  factory AuthenticationModel.fromJson(Map<String, dynamic> json) {
    return AuthenticationModel(
      token: json['token'] ?? "",
      status: json['status'] ?? 0,
      message: json['message'] ?? "",
      user: (json['user'] is Map)
          ? User.fromJson(json['user'])
          : User(id: "", name: "", email: "", password: ""),
    );
  }
}

class User {
  final String id;
  final String name;
  final String email;
  final String password;

  User(
      {required this.id,
      required this.name,
      required this.email,
      required this.password});

  Map<String, String> toJson() {
    return {'id': id, 'nama': name, 'email': email, 'password': password};
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id'] ?? "",
        name: json['nama'] ?? "",
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
