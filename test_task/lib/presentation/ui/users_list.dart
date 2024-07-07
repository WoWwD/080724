import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_task/presentation/ui/user_card_widget.dart';
import '../bloc/user_bloc.dart';

class UsersList extends StatefulWidget {
  final String startLetter;
  final String endLetter;

  const UsersList({
    required this.startLetter,
    required this.endLetter,
    super.key,
  });

  @override
  State<UsersList> createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      context.read<UserBloc>().add(
        LoadUsers(startLetter: widget.startLetter, endLetter: widget.endLetter)
      );
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        return switch(state) {
          UserInitial() => const Center(child: CircularProgressIndicator()),
          UserLoading() => const Center(child: CircularProgressIndicator()),
          UserError() => Center(child: Text('Error: ${state.message}')),
          UserLoaded() => _UsersLoadedWidget(
            state: state,
            scrollController: _scrollController
          ),
          UserSearched() => _UsersSearchedWidget(state: state)
        };
      }
    );
  }
}

class _UsersLoadedWidget extends StatelessWidget {
  final UserLoaded state;
  final ScrollController scrollController;

  const _UsersLoadedWidget({
    required this.state,
    required this.scrollController
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: state.users.length + (state.hasReachedMax ? 0 : 1),
      itemBuilder: (BuildContext context, int index) {
        if (index >= state.users.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            )
          );
        } else {
          return UserCardWidget(user: state.users[index]);
        }
      },
    );
  }
}

class _UsersSearchedWidget extends StatelessWidget {
  final UserSearched state;

  const _UsersSearchedWidget({required this.state});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: state.searchedUsers.length,
      itemBuilder: (BuildContext context, int index) {
        return UserCardWidget(user: state.searchedUsers[index]);
      },
    );
  }
}
