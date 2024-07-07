import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_task/presentation/ui/users_list.dart';
import '../../services/github/github_service.dart';
import '../bloc/user_bloc.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserBloc>(
      // first loading
      create: (context) => UserBloc(githubService: GithubService())
        ..add(LoadUsers(startLetter: 'A', endLetter: 'H')),
      child: const MainScreenWidget(),
    );
  }
}


class MainScreenWidget extends StatefulWidget {
  const MainScreenWidget({super.key});

  @override
  State<MainScreenWidget> createState() => _MainScreenWidgetState();
}

class _MainScreenWidgetState extends State<MainScreenWidget> with TickerProviderStateMixin {
  List<String> letters = ['A', 'H', 'I', 'P', 'Q', 'Z'];
  late TabController _tabController;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _tabController = TabController(vsync: this, length: 3);
    _tabController.addListener((){
      if(_tabController.indexIsChanging) {
        _tabViewUpdate(_tabController.index, letters, context);
      }
    });
  }

  void _onSearchChanged() => context.read<UserBloc>()
    .add(SearchUser(query: _searchController.text));

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _tabController,
          tabs: _generateTabs(letters)
        ),
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            suffixIcon: Icon(Icons.search),
            hintText: 'Type to search',
            border: InputBorder.none
          ),
          onChanged: (value) => _onSearchChanged(),
        ),
      ),
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: _generateTabViews(letters)
      ),
    );
  }
}

List<Widget> _generateTabs(List<String> letters) {
  List<Widget> tabs = [];

  for (int i = 0; i < letters.length - 1; i += 2) {
    tabs.add(Tab(text: '${letters[i]}-${letters[i + 1]}'));
  }
  return tabs;
}

List<Widget> _generateTabViews(List<String> letters) {
  List<Widget> tabViews = [];

  for (int i = 0; i < letters.length - 1; i += 2) {
    tabViews.add(
      UsersList(
        startLetter: letters[i],
        endLetter: letters[i + 1],
      ),
    );
  }

  return tabViews;
}

void _tabViewUpdate(int index, List<String> letters, BuildContext context) {
  switch(index){
    case 0: context.read<UserBloc>().add(ChangeTab(
      startLetter: letters[0],
      endLetter: letters[1])
    );
    case 1: context.read<UserBloc>().add(ChangeTab(
      startLetter: letters[2],
      endLetter: letters[3])
    );
    case 2: context.read<UserBloc>().add(ChangeTab(
      startLetter: letters[4],
      endLetter: letters[5])
    );
  }
}
