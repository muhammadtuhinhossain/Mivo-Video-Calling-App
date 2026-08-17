class UserListTileState {
  final bool isLoading;
  final String? requestStatus;
  final bool areFriends;
  final bool isRequestSender;
  final String? pendRequestId;

  UserListTileState({
    this.isLoading = false,
    this.requestStatus,
    this.areFriends = false,
    this.isRequestSender = false,
    this.pendRequestId,
});
  UserListTileState copyWith({
     bool? isLoading,
     String? requestStatus,
     bool? areFriends,
     bool? isRequestSender,
     String? pendRequestId,
}){
    return UserListTileState(
      isLoading: isLoading ?? this.isLoading,
      requestStatus: requestStatus ?? this.requestStatus,
      areFriends: areFriends ?? this.areFriends,
      isRequestSender: isRequestSender ?? this.isRequestSender,
      pendRequestId: pendRequestId ?? this.pendRequestId,
    );
  }
}
