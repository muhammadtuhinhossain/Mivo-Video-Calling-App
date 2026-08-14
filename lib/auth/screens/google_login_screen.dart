import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mivo/auth/service/google_auth_provider.dart';

class GoogleLoginScreen extends ConsumerWidget {
  const GoogleLoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final authState= ref.watch(googleAuthProvider);
    final authNotifier= ref.read(googleAuthProvider.notifier);

    WidgetsBinding.instance.addPostFrameCallback((_){
      if(authState.error != null){
        Future.delayed(Duration(milliseconds: 100),(){
          ref.read(googleAuthProvider.notifier).clearError();
        });
      }
    });
    return Column(
      children: [
        MaterialButton(
          elevation: 0,
            color: Colors.lightBlueAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            onPressed: authState.isLoading
            ?null
                :(){
            authNotifier.clearError();
            authNotifier.signInWithGoogle(context);
            },
          child: Padding(
            padding: const EdgeInsets.all(7.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
                  height: 30,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.account_circle_outlined, size: 30),
                ),
                SizedBox(width: 5,),
                Text(
                  authState.isLoading
                      ?"Signing In..."
                      :"Continue with Google",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600,color: Colors.black,letterSpacing: -0.5),
                ),
              ],
            ),
          ),
        ),
        if(authState.isLoading) CircularProgressIndicator(color: Colors.black,),
      ],
    );
  }
}

