import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mivo/auth/screens/signup_screen.dart';
import 'package:mivo/chat/screen/app_home_screen.dart';
import 'package:mivo/core/route.dart';
import 'package:mivo/core/utils/utils.dart';
import '../service/auth_provider.dart';
import '../service/auth_service.dart';
import 'google_login_screen.dart';

class UserLoginScreen extends ConsumerWidget {
  const UserLoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(authFormProvider);
    final formNotifier = ref.read(authFormProvider.notifier);
    final authMethod = ref.read(authMethodProvider);

    void login() async {
      formNotifier.setLoading(true);
      final res = await authMethod.loginUser(
        email: formState.email,
        password: formState.password,
      );
      formNotifier.setLoading(false);
      if (res == "success" && context.mounted) {
        NavigationHelper.pushAndRemoveUntil(context, const MainHomeScreen());
        showAppSnackbar(
          context: context,
          type: SnackbarType.success,
          description: "Login Successful",
        );
      } else {
        if (context.mounted) {
          showAppSnackbar(
            context: context,
            type: SnackbarType.error,
            description: res,
          );
        }
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // Illustration
              Center(
                child: Image.network(
                  'https://img.freepik.com/free-vector/online-messaging-concept-illustration_114360-4927.jpg',
                  height: 250,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 250,
                    width: double.infinity,
                    color: Colors.grey[100],
                    child: const Icon(Icons.image, size: 80, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Email Field
              TextField(
                onChanged: (value) => formNotifier.updateEmail(value),
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: const EdgeInsets.all(15),
                  errorText: formState.emailError,
                ),
              ),
              const SizedBox(height: 20),
              // Password Field
              TextField(
                onChanged: (value) => formNotifier.updatePassword(value),
                obscureText: formState.isPasswordHidden,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      formState.isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => formNotifier.togglePasswordVisibility(),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: const EdgeInsets.all(15),
                  errorText: formState.passwordError,
                ),
              ),
              const SizedBox(height: 30),
              // Login Button
              formState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : MyButton(
                      onTab: formState.email.isNotEmpty && formState.password.isNotEmpty ? login : null,
                      buttonText: 'Login',
                    ),
              const SizedBox(height: 20),
              // Divider
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text('or', style: TextStyle(color: Colors.grey)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 20),
              // Google Login Button
              const GoogleLoginScreen(),
              const SizedBox(height: 30),
              // Sign Up Text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () {
                      NavigationHelper.push(context, const SignupScreen());
                    },
                    child: const Text(
                      'SignUp',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
