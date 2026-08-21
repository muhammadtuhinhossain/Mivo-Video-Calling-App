import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // Add this for unawaited
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mivo/chat/screen/app_home_screen.dart';
import 'package:mivo/core/secret/secret.dart';
import 'package:mivo/core/wrapper%20state/app_state_manager.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

class AuthenticationWrapper extends ConsumerStatefulWidget {
  const AuthenticationWrapper({super.key});

  @override
  ConsumerState<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends ConsumerState<AuthenticationWrapper> {
  bool _isinitialized = false;

  @override
  void initState() {
    super.initState();
    _initializedSession();
  }

  Future<void> _initializedSession() async {
    try {
      final appManager = ref.read(appStateManagerProvider);
      
      // Run session initialization with timeout (max 10s)
      await appManager.initializedUserSession().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('Session initialization timed out');
        },
      );

      // Initialize Zego after user session is ready
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Initialize Zego without blocking the whole UI setup
        unawaited(ZegoUIKitPrebuiltCallInvitationService().init(
          appID: ZegoConfig.appID,
          appSign: ZegoConfig.appSign,
          userID: user.uid,
          userName: user.displayName ?? "User ${user.uid.substring(0, 4)}",
          plugins: [ZegoUIKitSignalingPlugin()],
          invitationEvents: ZegoUIKitPrebuiltCallInvitationEvents(),
        ).catchError((e) {
          debugPrint("Zego Init Error: $e");
          return false;
        }));
      }

      if (mounted) {
        setState(() {
          _isinitialized = true;
        });
      }
    } catch (e) {
      debugPrint("Error initializing session or Zego: $e");
      if (mounted) {
        // still allow moving forward even if init fails
        setState(() {
          _isinitialized = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isinitialized) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Setting up your account....."),
            ],
          ),
        ),
      );
    }
    return const MainHomeScreen();
  }
}
