class ProfileModel {
  ProfileModel({
    this.id = 1,
    required this.name,
    required this.email,
    required this.password,
  });

  final int id;
  final String name;
  final String email;
  final String password;

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        id: (json['id'] as int?) ?? 1,
        name: json['name'] as String,
        email: json['email'] as String,
        password: json['password'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'password': password,
      };
}
