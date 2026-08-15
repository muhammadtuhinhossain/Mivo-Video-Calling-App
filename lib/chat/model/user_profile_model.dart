class ProfileState {
  final String? photoUrl;
  final String? name;
  final String? email;
  final bool isLoading;
  final bool isUploading;
  final DateTime? createdAt;
  final DateTime? lastSeen;
  final String? userId;

  ProfileState({
    required this.photoUrl,
    required this.name,
    required this.email,
    required this.isLoading,
    required this.isUploading,
    required this.createdAt,
    required this.lastSeen,
    required this.userId,
  });

  ProfileState copyWith({
    String? photoUrl,
    String? name,
    String? email,
    DateTime? createdAt,
    DateTime? lastSeen,
    bool? isLoading,
    bool? isUploading,
    String? userId,
  }) {
    return ProfileState(
      photoUrl: photoUrl ?? this.photoUrl,
      name: name ?? this.name,
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
      isUploading: isUploading ?? this.isUploading,
      createdAt: createdAt ?? this.createdAt,
      lastSeen: lastSeen ?? this.lastSeen,
      userId: userId ?? this.userId,
    );
  }
}
