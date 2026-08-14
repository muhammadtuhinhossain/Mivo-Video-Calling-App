import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mivo/auth/model/google_auth_model.dart';
import 'package:mivo/auth/service/google_auth_service.dart';
import 'package:mivo/core/route.dart';
import 'package:mivo/chat/screen/app_home_screen.dart';
import 'package:mivo/core/utils/utils.dart';

class GoogleAuthNotifier extends StateNotifier<GoogleAuthState> {
  GoogleAuthNotifier() : super(GoogleAuthState(isLoading: false, error: null));

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final credential = await GoogleAuthService.signInWithGoogle();
      if (credential != null) {
        state = state.copyWith(isLoading: false);
        if (context.mounted) {
          showAppSnackbar(
            context: context,
            type: SnackbarType.success,
            description: "Google Login Successful",
          );
          NavigationHelper.pushAndRemoveUntil(context, const MainHomeScreen());
        }
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      if (context.mounted) {
        showAppSnackbar(
          context: context,
          type: SnackbarType.error,
          description: "Login Failed: ${e.toString()}",
        );
      }
    }
  }
}

final googleAuthProvider = StateNotifierProvider<GoogleAuthNotifier, GoogleAuthState>((ref) {
  return GoogleAuthNotifier();
});
