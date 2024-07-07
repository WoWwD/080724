import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import '../../data/user_model.dart';
import '../../services/github/github_service.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final GithubService githubService;
  bool isLoading = false;
  List<UserModel> allUsers = [];
  int currentSince = 0;

  UserBloc({required this.githubService}) : super(UserInitial()) {
    on<LoadUsers>((event, emit) async {
      if(isLoading) return;
      isLoading = true;

      try {
        final currentState = state;
        if (currentState is UserLoading && currentSince == 0) {
          emit(UserLoading());
        }

        final List<UserModel> users = await githubService.getUsers(since: currentSince);
        final List<UserModel> sortedUsersList = _sortUsers(users, event.startLetter, event.endLetter);

        if (currentState is UserLoaded) {
          emit(
            UserLoaded(
              users: currentState.users + sortedUsersList,
              hasReachedMax: sortedUsersList.isEmpty,
            ),
          );
        } else {
          emit(UserLoaded(users: sortedUsersList, hasReachedMax: sortedUsersList.isEmpty));
        }
        allUsers.addAll(users);
        currentSince = allUsers[allUsers.length - 1].id;
      } catch (e) {
        emit(UserError(message: e.toString()));
      }

      isLoading = false;
    });

    on<SearchUser>((event, emit) async {
      emit(UserLoading());
      final searchedUsers = await githubService.searchUsers(query: event.query);
      emit(UserSearched(searchedUsers: searchedUsers));
    });

    on<ChangeTab>((event, emit) {
      emit(UserLoading());
      final sortedUsers = _sortUsers(allUsers, event.startLetter, event.endLetter);
      emit(UserLoaded(users: sortedUsers, hasReachedMax: sortedUsers.isEmpty));
    });
  }

  List<UserModel> _sortUsers(List<UserModel> users, String startLetter, String endLetter) {
    final sortedUsersList = users.where((user) {
      final name = user.login.toUpperCase();
      return name.compareTo(startLetter) >= 0 && name.compareTo(_nextLetter(endLetter)) < 0;
    }).toList();

    sortedUsersList.sort((a, b) => a.login.toUpperCase().compareTo(b.login.toUpperCase()));
    return sortedUsersList;
  }

  String _nextLetter(String letter) {
    final code = letter.codeUnitAt(0);
    return String.fromCharCode(code + 1);
  }
}
