class UserModel {
  final int id;
  final String avatar;
  final String login;
  final int followers;
  final int following;

  const UserModel({
    required this.id,
    required this.avatar,
    required this.login,
    required this.followers,
    required this.following
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      avatar: json['avatar_url'],
      login: json['login'],
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0
    );
  }
}
