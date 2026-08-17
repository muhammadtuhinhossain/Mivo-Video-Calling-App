import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mivo/chat/provider/provider.dart';
import 'package:mivo/core/utils/utils.dart';

class RequestScreen extends ConsumerStatefulWidget {
  const RequestScreen({super.key});

  @override
  ConsumerState<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends ConsumerState<RequestScreen> {

  @override
  void initState() {
    // refresh request list as soon as screen opens
    WidgetsBinding.instance.addPostFrameCallback((_){
      ref.invalidate(requestProvider);
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final request = ref.watch(requestProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Message Request'),
        actions: [
          IconButton(
              onPressed: ()=> ref.invalidate(requestProvider),
              icon: Icon(Icons.refresh),
          );
        ],
      ),
    //handle provider states (date, loading error)
    body: request.when(
    data: (requestList){
      if(requestList.isEmpty){
        Center(
          child: Column(
        mainAxisAlignment: .center,
          children: [
            Icon(Icons.inbox,size: 64,color: Colors.grey,),
    SizedBox(height: 15,),
    Text("No pending request", style: TextStyle(fontSize: 18, color: Colors.grey),)
          ],
          ),
        );
    }
      //if request exists -> show list of request
    return ListView.builder(
      itemCount: requestList.length,
      itemBuilder: (context, index){
        final request = requestList[index];
        return Card(
    elevation: 0,
    margin: .all(8),
    child: ListTile(
    leading: CircleAvatar(
    radius: 28,
    backgroundImage: request.photoURL != null
    ?NetworkImage(request.photoURL!)
    :null,
    child: request.photoURL == null
    ?Icon(Icons.person,size: 30,)
    :null,
    ),
    title: Text(request.senderName),
    trailing: Row(
    mainAxisSize: .min,
    children: [
      //accept request
      GestureDetector(
    onTap: ()async{
      await ref
          .read(requestProvider.notifier)
          .acceptRequest(request.id, request.senderId);
      if(context.mounted){
        showAppSnackbar(
        context: context,
        type: SnackbarType.success,
    description: "Request accepted",
    );
        //Refresh all providers after accepting
    ref.invalidate(usersProvider);
    //ref.invalidate()
    }
    },
    child: CircleAvatar(
    backgroundColor: Colors.green,
    child: Icon(Icons.check, color: Colors.white),
    ),
    ),
    SizedBox(width: 10,),
    //reject request
    GestureDetector(
    onTap: ()async{
    await ref
        .read(requestProvider.notifier)
        .rejectRequest(request.id);
    if(context.mounted){
    showAppSnackbar(
    context: context,
    type: SnackbarType.success,
    description: "Request Rejected!",
    );
    }
    },
    child: CircleAvatar(
    backgroundColor: Colors.red,
    child: Icon(Icons.close, color: Colors.white),
    ),
    )
    ],
    ),
    ),
    );
    }
      );
    },
    error: (error, _)=> Center(
    child: Column(
    mainAxisAlignment: .center,
    children: [
      Text("Error: $error"),
    SizedBox(height: 16,),
    ElevatedButton(
    onPressed: ()=> ref.invalidate(requestProvider),
    child: Text('Retry'),
    )
    ],
    ),
    ),
    loading: ()=> Center(child: CircularProgressIndicator()),
    ),
    );
  }
}
