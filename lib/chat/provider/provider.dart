import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mivo/chat/model/chat_model.dart';
import 'package:mivo/chat/model/message_request_model.dart';
import 'package:mivo/chat/model/user_model.dart';
import 'package:mivo/chat/service/chat_service.dart';

//auth state
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

//chat service
final chatServiceProvider = Provider<ChatService>((ref) => ChatService());

// users
class UsersNotifier extends StateNotifier<AsyncValue<List<UserModel>>> {
  final ChatService _chatService;
  StreamSubscription<List<UserModel>>? _subscription;
  UsersNotifier(this._chatService) : super(AsyncValue.loading()) {
    _init();
  }

  void _init() {
    _subscription?.cancel();
    _subscription = _chatService.getAllUsers().listen(
      (users) => state = AsyncValue.data(users),
      onError: (error, stackTrace) =>
          state = AsyncValue.error(error, stackTrace),
    );
  }

  void refresh() => _init();
  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
  }
}

final usersProvider =
    StateNotifierProvider<UsersNotifier, AsyncValue<List<UserModel>>>((ref) {
      final service = ref.watch(chatServiceProvider);
      return UsersNotifier(service);
    });

//request
class RequestNotifier
    extends StateNotifier<AsyncValue<List<MessageRequestModel>>> {
  final ChatService _chatService;
  StreamSubscription<List<MessageRequestModel>>? _subscription;
  RequestNotifier(this._chatService) : super(AsyncValue.loading()) {
    _init();
  }

  void _init() {
    _subscription?.cancel();
    _subscription = _chatService.getPendingRequest().listen(
      (requests) => state = AsyncValue.data(requests),
      onError: (error, stackTrace) =>
          state = AsyncValue.error(error, stackTrace),
    );
  }

  Future<void> acceptRequest(String requestId, String senderId)async{
    await _chatService.acceptMessageRequest(requestId, senderId);
    _init();
  }
  Future<void> rejectRequest(String requestId)async{
    await _chatService.rejectionMessageRequest(requestId);
    _init();
  }

  void refresh()=> _init();
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _subscription?.cancel();
  }
}
final requestProvider =
StateNotifierProvider<RequestNotifier, AsyncValue<List<MessageRequestModel>>>((ref) {
  final service = ref.watch(chatServiceProvider);
  return RequestNotifier(service);
});

//auto refresh on auth change
final autoRefreshProvider = Provider<void>((ref){
  ref.listen<AsyncValue<User?>>(authStateProvider, (prev, next){
    next.whenData((user){
      if(user != null){
        Future.delayed(Duration(milliseconds: 500),(){
          ref.invalidate(usersProvider);
          ref.invalidate(requestProvider);
        });
      }
    });
  });
});

//Chat
class ChatsNotifier extends StateNotifier<AsyncValue<List<ChatModel>>>{
  final ChatService _chatService;
  StreamSubscription<List<ChatModel>>? _subscription;
  ChatsNotifier(this._chatService) : super(AsyncValue.loading()) {
    _init();
  }

  void _init() {
    _subscription?.cancel();
    _subscription = _chatService.getUserChats().listen(
          (chats) => state = AsyncValue.data(chats),
      onError: (error, stackTrace) =>
      state = AsyncValue.error(error, stackTrace),
    );
  }
  void refresh()=> _init();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _subscription?.cancel();
  }
}
final chatsProvider = StateNotifierProvider<ChatsNotifier, AsyncValue<List<ChatModel>>>((ref){
  final service = ref.watch(chatServiceProvider);
  return ChatsNotifier(service);
});

//search
final searchQueryProvider = StateProvider<String>((ref)=> '');

final filteredUsersProvider = Provider<AsyncValue<List<UserModel>>>((ref){
  final users = ref.watch(usersProvider);
  final query = ref.watch(searchQueryProvider);
  return users.when(
      data: (list){
        if(query.isEmpty)return AsyncValue.data(list);
        return AsyncValue.data(
          list
              .where(
              (u)=>
              u.name.toLowerCase().contains(query.toLowerCase()) ||
                  u.email.toLowerCase().contains(query.toLowerCase()),

          ).toList(),
        );
      },
      error: (error, stackTrace)=> AsyncValue.error(error, stackTrace),
      loading: ()=> AsyncValue.loading(),
  );
});