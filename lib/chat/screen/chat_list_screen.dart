import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mivo/chat/model/user_model.dart';
import 'package:mivo/chat/provider/provider.dart';
import 'package:mivo/chat/provider/user_status_provider.dart';
import 'package:mivo/chat/screen/chat%20screen/chat_screen.dart';
import 'package:mivo/chat/screen/request_screen.dart';
import 'package:mivo/core/route.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {

  @override
  void initState() {
    super.initState();
    // when screen loads, refresh chat and request providers
    WidgetsBinding.instance.addPostFrameCallback((_){
      ref.invalidate(requestProvider);
      ref.invalidate(chatsProvider);
    });
  }
  //manual refresh (pull-to-refresh action)
  Future<void> _onRefresh()async{
    ref.invalidate(requestProvider);
    ref.invalidate(chatsProvider);
    await Future.delayed(Duration(milliseconds: 500));
  }
  @override
  Widget build(BuildContext context) {
    final pendingRequests = ref.watch(requestProvider);
    final chats = ref.watch(chatsProvider);
    final requestCount = pendingRequests.when(
        data: (requests)=> requests.length,
        error: (error, stackTrace)=> 0,
        loading: ()=> 0,
    );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Text("Chats", style: TextStyle(fontWeight: .w600),),
        actions: [
          //Notification icon only if there are pending request
          if(requestCount > 0)
            IconButton(
                onPressed: ()=> NavigationHelper.push(context, RequestScreen()),
                icon: Stack(
                  children: [
                    Icon(Icons.notifications),
                    Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$requestCount',
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ))
                  ],
                )
            ),
        ],
      ),
      //pull-to-refresh + chat list display
      body: RefreshIndicator(
          onRefresh: _onRefresh,
          child: chats.when(
              data: (chatsList) {
                if(chatsList.isEmpty){
                  return ListView(
                    physics: AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: 200,),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16,),
                            Text("No chats yet",
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            SizedBox(height: 8,),
                            Text("Go to Users tab to send message request",
                              style: TextStyle(color: Colors.grey),
                            )
                          ],
                        ),
                      )
                    ],
                  );
                }
                //if chats exist-> show chat list
                return ListView.builder(
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount: chatsList.length,
                    itemBuilder: (context, index){
                      final chat = chatsList[index];

                      return FutureBuilder<UserModel?>(
                          future: _getOtherUser(chat.participants),
                          builder: (context, snapshot){
                            if(!snapshot.hasData) return SizedBox();

                            final otherUser = snapshot.data!;
                            final currentUserId = FirebaseAuth.instance.currentUser?.uid;
                            if(currentUserId == null) return SizedBox();

                            return ListTile(
                              //user profile + online/offline
                              leading: Stack(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: otherUser.photoURL != null
                                        ? NetworkImage(otherUser.photoURL!)
                                        :null,
                                    child: otherUser.photoURL == null
                                        ? Text(otherUser.name.isNotEmpty ? otherUser.name[0].toUpperCase() : "U")
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 2,
                                    child: Consumer(
                                        builder: (context, ref, _){
                                          final statusAsync = ref.watch(
                                          userStatusProvider(otherUser.uid),
                                          );
                                          return statusAsync.when(
                                                                data: (isOnline)=> CircleAvatar(
                                                                  radius: 5,
                                                                  backgroundColor: isOnline
                                                                  ?Colors.green
                                                                  :Colors.grey,
                                                                ),
                                                                error: (_, _)=> Text(otherUser.email),
                                                                loading: ()=> Text(otherUser.email),
                                                                );
                                                                }
                                    ),
                                  ),
                                ],
                              ),
                              //name of the user
                              title: Text(otherUser.name),
                              subtitle: Text(
                                  "You can now start to chat",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: ()=> NavigationHelper.push(
                                  context,
                                  ChatScreen(chatId: chat.chatId, otherUser: otherUser),
                              ),
                            );
                          }
                      );
                    }
                );
              },

          loading: ()=> Center(child: const CircularProgressIndicator()),
            error: (error, _)=> ListView(
              children: [
                SizedBox(height: 200,),
                Center(
                  child: Column(
                    children: [
                      Text("Error: $error"),
                      SizedBox(height: 16,),
                      ElevatedButton(onPressed: _onRefresh, child: Text('Retry'),),
                    ],
                  ),
                )
              ],
            ),

          )
      ),
    );
  }
  //get details of the other user in chat
  Future<UserModel?> _getOtherUser(List<String>participants)async{
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if(currentUserId == null)return null;
    final otherUserId = participants.firstWhere((id)=> id != currentUserId);
    try{
      final doc = await FirebaseFirestore.instance.collection("users")
          .doc(otherUserId)
          .get();

      return doc.exists ? UserModel.fromMap(doc.data()!):null;
    }catch(e){
      print('Error getting other user: $e');
      return null;
    }
  }
}
