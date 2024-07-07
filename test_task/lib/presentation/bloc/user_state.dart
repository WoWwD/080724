part of 'user_bloc.dart';

@immutable
sealed class UserState {}

final class UserInitial extends UserState {}
final class UserLoading extends UserState {}

final class UserLoaded extends UserState {
  final List<UserModel> users;
  final bool hasReachedMax;

  UserLoaded({required this.users, required this.hasReachedMax});
}

final class UserError extends UserState {
  final String message;

  UserError({required this.message});
}

final class UserSearched extends UserState {
  final List<UserModel> searchedUsers;

  UserSearched({required this.searchedUsers});
}
