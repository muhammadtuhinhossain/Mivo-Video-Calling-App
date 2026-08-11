class GoogleAuthState {
  final bool isLoading;
  final String? error;

  GoogleAuthState({required this.isLoading, required this.error});

  GoogleAuthState copyWith({bool? isLoading, String? error}){
    return GoogleAuthState(
        isLoading: isLoading ?? this.isLoading,
        error: error
    );
  }
}