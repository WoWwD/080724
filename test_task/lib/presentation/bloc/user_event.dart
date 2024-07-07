part of 'user_bloc.dart';

@immutable
sealed class UserEvent {}

class LoadUsers extends UserEvent {
  final String startLetter;
  final String endLetter;

  LoadUsers({
    required this.startLetter,
    required this.endLetter
  });
}

class SearchUser extends UserEvent {
  final String query;

  SearchUser({required this.query});
}

class ChangeTab extends UserEvent {
  final String startLetter;
  final String endLetter;

  ChangeTab({required this.startLetter, required this.endLetter});
}