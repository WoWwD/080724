import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:test_task/services/github/github_api.dart';
import '../../data/user_model.dart';

class GithubService extends GithubApi {
  Future<List<UserModel>> getUsers({required int since}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users?since=$since&per_page=100'),
      headers: { HttpHeaders.authorizationHeader: 'Bearer $token' },
    );

    if (response.statusCode == 200) {
      final List json = jsonDecode(response.body);

      final users = await Future.wait(
        json.map((json) async {
          final user = UserModel.fromJson(json);
          try {
            final userDetails = await getUserInfo(user.login);
            return UserModel(
              id: user.id,
              avatar: user.avatar,
              login: user.login,
              followers: userDetails['followers'],
              following: userDetails['following'],
            );
          } catch (e) {
            return null;
          }
        }).toList(),
      );
      return users.where((user) => user != null).cast<UserModel>().toList();
    } else {
      throw Exception('Failed to load users, code: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getUserInfo(String login) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$login'),
      headers: { HttpHeaders.authorizationHeader: 'Bearer $token' },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user details, code: ${response.statusCode}');
    }
  }

  Future<List<UserModel>> searchUsers({required String query}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/search/users?q=$query&per_page=100'),
      headers: { HttpHeaders.authorizationHeader: 'Bearer $token' },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      final List usersJson = json['items'];

      final users = await Future.wait(
        usersJson.map((json) async {
          final user = UserModel.fromJson(json);
          try {
            final userDetails = await getUserInfo(user.login);
            return UserModel(
              id: user.id,
              avatar: user.avatar,
              login: user.login,
              followers: userDetails['followers'],
              following: userDetails['following'],
            );
          } catch (e) {
            return null;
          }
        }).toList(),
      );
      return users.where((user) => user != null).cast<UserModel>().toList();
    } else {
      throw Exception('Failed to search users, code: ${response.statusCode} ');
    }
  }
}
