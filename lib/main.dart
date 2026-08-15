import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mivo/auth/screens/user_login_screen.dart';
import 'package:mivo/chat/provider/provider.dart';
import 'package:mivo/core/wrapper%20state/auth_wrapper.dart';
import 'package:mivo/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //watching authStateProvider -> listens to firebase auth changes
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: authState.when(
        data: (user) {
          //if user is logged in, go to AuthenticationWrapper
          if(user != null){
            return const AuthenticationWrapper();
          }else{
            // if not logged in, go to login screen
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
