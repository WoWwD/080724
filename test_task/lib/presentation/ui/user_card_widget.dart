import 'package:flutter/material.dart';
import 'package:test_task/data/user_model.dart';

class UserCardWidget extends StatelessWidget {
  final UserModel user;

  const UserCardWidget({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(user.avatar),
      ),
      title: Text(user.login),
      subtitle: Text('${user.followers} / ${user.following}'),
    );
  }
}
