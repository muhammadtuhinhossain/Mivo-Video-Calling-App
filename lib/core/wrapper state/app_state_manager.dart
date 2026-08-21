import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appStateManagerProvider = ChangeNotifierProvider<AppStateManager>((ref) {
  return AppStateManager();
});

class AppStateManager extends ChangeNotifier with WidgetsBindingObserver{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  AppStateManager() {
    //listen to app lifecycle change (resume, pause, etc)
    WidgetsBinding.instance.addObserver(this);
    // Initialized session when class is created
    initializedUserSession();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _setOnlineStatus(false); //mark user offline on dispose
    super.dispose();
  }

  //handle app lifecycle to update online/offline
  @override
  void didChangeAppLifecycleState(AppLifecycleState state){
    switch (state){
      case AppLifecycleState.resumed:
        _setOnlineStatus(true);//mark online when resumed
    break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        _setOnlineStatus(false); //mark offline otherwise
    break;
    default:
      break;
    }
  }

  // Initialize user session (run once per app start)
  Future<void> initializedUserSession() async {
    if (_isInitialized) return;

    final user = _auth.currentUser;
    if (user == null) {
      _isInitialized = true;
      notifyListeners();
      return;
    }

    try {
      final userDoc = _firestore.collection("users").doc(user.uid);
      final snapshot = await userDoc.get();

      // If user doc doesn't exist -> create new
      if (!snapshot.exists) {
        await userDoc.set({
          'uid': user.uid,
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'photoURL': user.photoURL ?? '',
          'provider': _getProvider(user),
          'isOnline': true,
          'lastSeen': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        // If exists -> just update online status + lastSeen
        await userDoc.update({
          'isOnline': true,
          'lastSeen': FieldValue.serverTimestamp(),
        });
      }
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing session: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }
  //set user online/offline
  Future<void> _setOnlineStatus(bool isOnline)async{
    final user = _auth.currentUser;
    if(user == null) return;
    try{
      await _firestore.collection("users").doc(user.uid).update({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    }catch(e){
      print('Error updating online status: $e');
    }
  }
  //public metho to manually set online status
  Future<void> updateOnlineStatus(bool isOnline)async{
    await _setOnlineStatus(isOnline);
  }

  // Detects which provider user used (google or email)
  String _getProvider(User user) {
    for (UserInfo info in user.providerData) {
      if (info.providerId == "google.com") return 'google';
      if (info.providerId == "password") return 'email';
    }
    return 'email';
  }
}
