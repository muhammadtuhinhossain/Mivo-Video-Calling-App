import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mivo/chat/model/user_list_model.dart';
import 'package:mivo/chat/model/user_model.dart';
import 'package:mivo/chat/provider/user_list_provider.dart';
import 'package:mivo/chat/screen/chat%20screen/chat_screen.dart';
import 'package:mivo/core/route.dart';
import 'package:mivo/core/utils/chat_id.dart';
import 'package:mivo/core/utils/utils.dart';

class UserListTile extends ConsumerWidget {
  const UserListTile({super.key, required this.user});
  final UserModel user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userListProvider(user));
    final notifier = ref.read(userListProvider(user).notifier);
    final hasPhoto = user.photoURL != null && user.photoURL!.isNotEmpty;
    return ListTile(
      leading:  CircleAvatar(
        backgroundImage: hasPhoto
            ? NetworkImage(user.photoURL!)
            :null,
        child: !hasPhoto
            ? Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : "U")
            :null,
      ),
      title: Text(user.name, maxLines: 1, overflow: TextOverflow.ellipsis,),
      //show online / offline status in subtitle
      subtitle: Text("Offline"),//we will make if functional some time later
      //Rifht-side action button (char, add friend, accept request, etc)
      trailing: _buildTrailingWidget(context, ref, state, notifier),
    );
  }
  Widget _buildTrailingWidget(BuildContext context, WidgetRef ref, UserListTileState state, UserListNotifier notifier,){
    if(state.isLoading){
      //show loading spinner while checking status
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2,),
      );
    }
    //already friend -> show "chat" button
    if(state.areFriends){
      return MaterialButton(
          color: Colors.green,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: .circular(10)),
          onPressed: ()=> _navigateToChat(context),
        child: buttonName(Icons.chat, "Chat"),
      );
    }
    //current user sent the request -> show "Pending"
    if(state.requestStatus == "pending"){
      if(state.isRequestSender){
        return ElevatedButton(
            onPressed: null,
            child: SizedBox(
              width: 100,
              height: 32,
              child: Row(
                mainAxisAlignment: .center,
                children: [
                 Icon(Icons.pending_actions, color: Colors.black,size: 20,),
                 SizedBox(width: 5,),
                 Text(
                   "Pending",
                   style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: .w600,),
                 )
                ],
              ),
            )
        );
      }else{
        // current user received the request -> show accept button
        return MaterialButton(
          color: Colors.orange,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: .circular(10),
            ),
            onPressed: ()async{
            final result = await notifier.acceptRequest();
            if(result == "success" && context.mounted){
              showAppSnackbar(
                context: context,
                type: SnackbarType.success,
                description: "Request Accept",
              );
            }else{
              if(context.mounted){
                showAppSnackbar(
                  context: context,
                  type: SnackbarType.error,
                  description: "Failed $result",
                );
              }
            }
            },
          child: buttonName(Icons.done, "Accept"),
        );
      }
    }
    //default -> not friend ter -> show "add friend" button
    return MaterialButton(
        color: Colors.blueAccent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: .circular(10)),
        onPressed: ()async{
          final result = await notifier.sendRequest();
          if(result == "success" && context.mounted){
            showAppSnackbar(
              context: context,
              type: SnackbarType.success,
              description: "Request send successfully",
            );
          }else{
            if(context.mounted){
              showAppSnackbar(
                context: context,
                type: SnackbarType.error,
                description: result,
              );
            }
          }
        },
      child: buttonName(Icons.person, "Add friend"),
    );
  }
  SizedBox buttonName(IconData icon, String name){
    return SizedBox(
      height: 32,
      width: 100,
      child: Row(
        mainAxisAlignment: .center,
        children: [
          Icon(icon, color: Colors.white,size: 25,),
          SizedBox(width: 5,),
          Text(
            name,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: .w600,
            ),
          )
        ],
      ),
    );
  }
  //Navigator to chat screen when "Chat button clicked"
Future<void> _navigateToChat(BuildContext context)async{
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final chatId = generateChatID(currentUserId, user.uid);
    NavigationHelper.push(context, ChatScreen(chatId: chatId, otherUser: user));
}
//Generate unique chatId between Users
}
