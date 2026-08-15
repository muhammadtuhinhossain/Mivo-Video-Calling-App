import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mivo/chat/model/user_profile_model.dart';

class ProfileNotifier extends StateNotifier<ProfileState> {
  late final StreamSubscription<User?> _authSubscription;

  ProfileNotifier()
      : super(ProfileState(
          photoUrl: null,
          name: null,
          email: null,
          isLoading: true,
          isUploading: false,
          createdAt: null,
          lastSeen: null,
          userId: null,
        )) {
    _listenToAuthChanges();
  }

  //listen to firebase auth state changes
  void _listenToAuthChanges() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        //user logged in load their data
        if (state.userId != user.uid) {
          //only reload if it's a different user
          loadUserData(user);
        }
      } else {
        //user logged out-clear state
        state = ProfileState(
          photoUrl: null,
          name: null,
          email: null,
          isLoading: false,
          isUploading: false,
          createdAt: null,
          lastSeen: null,
          userId: null,
        );
      }
    });
  }

//load user data from firebase
  Future<void> loadUserData([User? user]) async {
    final currentUser = user ?? FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      state = state.copyWith(isLoading: false);
      return;
    }
    state = state.copyWith(isLoading: true);
    try {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        String? photoUrl = data?['photoURL'] ?? data?['photoUrl'];
        if (photoUrl != null && photoUrl.isEmpty) photoUrl = null;

        state = ProfileState(
          photoUrl: photoUrl,
          name: data?['name'],
          email: data?['email'],
          isLoading: false,
          isUploading: false,
          createdAt: (data?['createdAt'] as Timestamp?)?.toDate(),
          lastSeen: (data?['lastSeen'] as Timestamp?)?.toDate(),
          userId: currentUser.uid,
        );
      } else {
        state = state.copyWith(userId: currentUser.uid, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(userId: currentUser.uid, isLoading: false);
    }
  }

// force refresh user data
  void refresh() {
    loadUserData();
  }

// pick and upload new profile image
  Future<bool> updateProfilePicture() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    final picker = ImagePicker();
    final pickerFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickerFile == null) return false;
    state = state.copyWith(isUploading: true);

    File file = File(pickerFile.path);

    try {
      // upload to firebase storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child("profile_pictures")
          .child("${user.uid}.jpg");

      await storageRef.putFile(file);
      final newUrl = await storageRef.getDownloadURL();

      // update firestore
      await FirebaseFirestore.instance.collection("users").doc(user.uid).update({
        "photoURL": newUrl,
        "lastSeen": FieldValue.serverTimestamp(),
      });

      // Update local state
      state = state.copyWith(
        photoUrl: newUrl,
        isUploading: false,
        lastSeen: DateTime.now(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(isUploading: false);
      return false;
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}

//provider
final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier();
});
