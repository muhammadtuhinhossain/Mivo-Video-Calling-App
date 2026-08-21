import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mivo/chat/model/user_list_model.dart';
import 'package:mivo/chat/model/user_model.dart';
import 'package:mivo/chat/provider/provider.dart';

class UserListNotifier extends StateNotifier<UserListTileState> {
  final Ref ref;
  final UserModel user;

  UserListNotifier(this.ref, this.user) : super(UserListTileState()) {
    _checkRelationship();
  }
  //check the status
  Future<void> _checkRelationship() async {
    final chatService = ref.read(chatServiceProvider);
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final friends = await chatService.areUsersFriends(currentUserId, user.uid);

    if (friends) {
      state = state.copyWith(
        areFriends: true,
        requestStatus: null,
        isRequestSender: false,
        pendRequestId: null,
      );
      return;
    }

    final sentRequestId = '${currentUserId}_${user.uid}';
    final receiverRequestId = '${user.uid}_$currentUserId';

    final sendRequestDoc = await FirebaseFirestore.instance
        .collection("messageRequests")
        .doc(sentRequestId)
        .get();

    final receiverRequestDoc = await FirebaseFirestore.instance
        .collection("messageRequests")
        .doc(receiverRequestId)
        .get();

    String? finalStatus;
    bool isSender = false;
    String? requestId;

    if (sendRequestDoc.exists) {
      final sentStatus = sendRequestDoc['status'];
      if (sentStatus == 'pending') {
        finalStatus = 'pending';
        isSender = true;
        requestId = sentRequestId;
      }
    }

    if (receiverRequestDoc.exists && finalStatus == null) {
      final receivedStatus = receiverRequestDoc['status'];
      if (receivedStatus == 'pending') {
        finalStatus = 'pending';
        isSender = false;
        requestId = receiverRequestId;
      }
    }

    state = state.copyWith(
      areFriends: false,
      requestStatus: finalStatus,
      isRequestSender: isSender,
      pendRequestId: requestId,
    );
  }

  Future<String> sendRequest() async {
    state = state.copyWith(isLoading: true);
    final chatservice = ref.read(chatServiceProvider);
    final result = await chatservice.sendMessageRequest(
      receiverId: user.uid,
      receiverName: user.name,
      receiverEmail: user.email,
    );
    if (result == 'success') {
      state = state.copyWith(
        isLoading: false,
        requestStatus: 'pending',
        isRequestSender: true,
        pendRequestId: '${FirebaseAuth.instance.currentUser!.uid}_${user.uid}',
      );
    } else {
      state = state.copyWith(isLoading: false);
    }
    return result;
  }

  Future<String> acceptRequest() async {
    if (state.pendRequestId == null) return 'no-request';

    state = state.copyWith(isLoading: true);
    final chatService = ref.read(chatServiceProvider);
    final result = await chatService.acceptMessageRequest(
      state.pendRequestId!,
      user.uid,
    );
    if (result == 'success') {
      state = state.copyWith(
        isLoading: false,
        areFriends: true,
        requestStatus: null,
        isRequestSender: false,
        pendRequestId: null,
      );
      //refresh provider
      ref.invalidate(requestProvider);
      ref.invalidate(chatsProvider);
    } else {
      state = state.copyWith(isLoading: false);
    }
    return result;
  }
}

final userListProvider =
    StateNotifierProvider.family<
        UserListNotifier,
        UserListTileState,
        UserModel
    >((ref, user) => UserListNotifier(ref, user));
