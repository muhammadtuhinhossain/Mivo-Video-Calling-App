import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mivo/chat/provider/user_status_provider.dart';
import 'package:mivo/chat/screen/chat%20screen/chat_screen.dart';

class UserChatProfile extends StatelessWidget {
  const UserChatProfile({super.key, required this.widget});
  final ChatScreen widget;

  @override
  Widget build(BuildContext context) {
    return Consumer(
        builder: (context, ref, _){
          final statusAsync = ref.watch(userStatusProvider(widget.otherUser.uid));

          return statusAsync.when(
              data: (isOnline)=> Row(
                children: [
                  CircleAvatar(
                    backgroundImage: widget.otherUser.photoURL != null
                        ? NetworkImage(widget.otherUser.photoURL!)
                        :null,
                    child: widget.otherUser.photoURL == null
                        ? Text(widget.otherUser.name.isNotEmpty
                        ? widget.otherUser.name[0].toUpperCase()
                        : "U",
                    )
                        :null,
                  ),
                  SizedBox(width: 12,),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        Text(widget.otherUser.name, style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            loading: ()=>Text(widget.otherUser.name),
            error: (_, _)=>Text(widget.otherUser.name) ,
          );
        }
    );
  }
}
