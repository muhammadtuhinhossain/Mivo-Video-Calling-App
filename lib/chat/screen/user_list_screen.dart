import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mivo/chat/provider/provider.dart';
import 'package:mivo/chat/widgets/user_list_tile.dart';

class UserListScreen extends ConsumerStatefulWidget {
  const UserListScreen({super.key});

  @override
  ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen> {

  @override
  void initState() {
    //force refresh when screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_){
      ref.invalidate(usersProvider);
    });
    super.initState();
  }
  Future<void> onRefresh() async {
    ref.invalidate(usersProvider);
    ref.invalidate(requestProvider);
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    //watch teh auto-refresh provider to trigger refreshes
    ref.watch(autoRefreshProvider);
    final users = ref.watch(filteredUsersProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("All Users"),
        backgroundColor: Colors.white,
        centerTitle: true,
        bottom: PreferredSize(
            preferredSize: Size.fromHeight(56),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: TextField(
                onChanged: (value)=>
                ref.read(searchQueryProvider.notifier).state= value,
                decoration: InputDecoration(
                  hintText: 'Search user by name or email...',
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: searchQuery.isNotEmpty
                    ?IconButton(onPressed: ()=> ref.read(searchQueryProvider.notifier).state = '',
                      icon: Icon(Icons.clear),
                  )
                      :null,
                  border: OutlineInputBorder(
                    borderRadius: .all(Radius.circular(25)),
                  ),
                  contentPadding: .symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            )
        ),
      ),
      body: RefreshIndicator(
        backgroundColor: Colors.white,
        onRefresh: onRefresh,
        child: users.when(
          data: (userlist) {
            if (userlist.isEmpty && searchQuery.isNotEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 200),
                  Center(child: Text('No users found matching your search')),
                ],
              );
            }
            if (userlist.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 200),
                  Center(child: Text("No other users found")),
                ],
              );
            }
            return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: userlist.length,
                itemBuilder: (context, index) {
                  final user = userlist[index];
                  return UserListTile(user: user);
                });
          },
          error: (error, _) => ListView(
            children: [
              const SizedBox(height: 200),
              Center(
                child: Column(
                  children: [
                    Text('Error: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(usersProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
