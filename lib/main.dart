import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mivo/auth/screens/user_login_screen.dart';
import 'package:mivo/chat/provider/provider.dart';
import 'package:mivo/core/wrapper%20state/auth_wrapper.dart';
import 'package:mivo/firebase_options.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import 'core/secret/secret.dart';

//1.1.1 define a navigator key
final navigatorKey = GlobalKey<NavigatorState>();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //request permission before initializing zego
  await requestPermission();
  final user = FirebaseAuth.instance.currentUser;
  final String userId= user?.uid ?? "000";
  final String userName= user?.displayName ?? "Guest";

  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);
  
  runApp(ProviderScope(child: MyApp(navigatorKey: navigatorKey,)));
}
Future<void> requestPermission()async{
  await [
    Permission.camera,
    Permission.microphone,
    Permission.notification,
  ].request();
}

class MyApp extends ConsumerWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const MyApp({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //watching authStateProvider -> listens to firebase auth changes
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: authState.when(
        data: (user) {
          //if user is logged in, go to AuthenticationWrapper
          if(user != null){
            return const AuthenticationWrapper();
          }else{
            // if not logged in, uninit Zego and go to login screen
            ZegoUIKitPrebuiltCallInvitationService().uninit();
            return const UserLoginScreen();
          }
        } ,
        error: (error, _) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,size: 64, color: Colors.red,),
                const SizedBox(height: 16,),
                Text("Error: $error"),
                ElevatedButton(onPressed: ()=> ref.invalidate(authStateProvider),
                    child: const Text("Retry"),
                ),
              ],
            ),
          ),
        ),
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator()),),
      ),
    );
  }
}
