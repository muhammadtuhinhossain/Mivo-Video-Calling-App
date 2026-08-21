import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mivo/chat/model/user_model.dart';
import 'package:mivo/chat/provider/provider.dart';
import 'package:mivo/chat/screen/chat%20screen/widgets/user_chat_profile.dart';
import 'package:mivo/chat/screen/chat%20screen/widgets/video_audio_call_button.dart';
import 'package:mivo/core/utils/utils.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.chatId, required this.otherUser});
  final String chatId;
  final UserModel otherUser;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    final chatService = ref.read(chatServiceProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: Colors.white,
        title: UserChatProfile(widget: widget),
          //in appBar actions: we will implement a video and audion call feature,
          actions: [
            //audio call
            actionButton(false, widget.otherUser.uid, widget.otherUser.name),
            //video call
            actionButton(true, widget.otherUser.uid, widget.otherUser.name),
            //popup menu-> unfriend option
            PopupMenuButton(
              onSelected: (value)async{
                if(value == 'Unfriend'){
                  final result = await showDialog(
                      context: context,
                      builder: (context)=> AlertDialog(
                        title: Text("Unfriend User"),
                        content: Text(
                          "Are you sure you want to unfriend ${widget.otherUser.name}?",
                        ),
                        actions: [
                          TextButton(onPressed: ()=> Navigator.pop(context, false),
                              child: Text("Cancel"),
                          ),
                          TextButton(onPressed: ()=> Navigator.pop(context, true),
                            child: Text("Unfriend"),
                          )
                        ],
                      )
                  );
                  //if confirmed -> unfriend
                  if(result == true){
                    final unfriendResult = await ref
                        .read(chatServiceProvider)
                        .unfriendUser(widget.chatId, widget.otherUser.uid);

                    if(unfriendResult == "success" && context.mounted){
                      Navigator.pop(context);
                      showAppSnackbar(
                        context: context,
                        type: SnackbarType.success,
                        description: "Your Friendship is Disconnect",
                      );
                    }
                  }
                }
              },
                itemBuilder: (context)=>[
                  PopupMenuItem(value:"Unfriend", child: Text("Unfriend")),
                ],
            )
          ]
      ),
      //chat body
      body: Column(
        //message section
        children: [
          Expanded(
            child: StreamBuilder(
                stream: chatService.getChatMessage(widget.chatId),
                builder: (context, snapshot){
                  if(snapshot.connectionState == ConnectionState.waiting){
                    return Center(child: CircularProgressIndicator());
                  }
                  if(snapshot.hasError){
                    return Center(child: Text("Error :${snapshot.error}"));
                  }
                  final messages =  snapshot.data ?? [];
                  if(snapshot.hasData && messages.isNotEmpty){
                    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
                  }
                  if(messages.isEmpty){
                    return Center(
                      child: Text("No message yet. Start the conversation!",
                      style: TextStyle(color: Colors.grey),
                      )
                    );
                  }
                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                      itemBuilder: (context, index){
                        final message = messages[index];
                        final isMe = message.senderId == FirebaseAuth.instance.currentUser!.uid;
                        final isSystem  = message.type == "system";
                        return Column(
                          children: [
                            //system generate message when us you are friend
                            if(isSystem)
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                message.message,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                              //display audio and video call history
                            else if(message.type == "call")
                              Container()
                            else
                              Container(),
                          ],
                        );
                      }
                  );
                }
            ),
          ),
          Container(
            padding: .only(top: 5, right: 10, left: 10, bottom: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 4,
                  spreadRadius: 1,
                  offset: Offset(0, -1),
                  color: Colors.grey.withAlpha(100),
                )
              ]
            ),
            child: Row(
              children: [
                IconButton(onPressed: (){}, icon: Icon(Icons.image,size: 30)),
                Expanded(
                    child: TextField(
                  decoration: InputDecoration(
                    hintText: "Text a message...",
                    border: OutlineInputBorder(
                      borderRadius: .circular(25),
                      borderSide: .none,
                    )
                  ),
                      maxLines: null,
                ),
                ),
                SizedBox(width: 8,),
                FloatingActionButton(
                  onPressed: (){},
                mini: true,
                  elevation: 0,
                  backgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(20),
                  ),
                  child: Icon(Icons.send, color:Colors.blueAccent,size: 25,),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
