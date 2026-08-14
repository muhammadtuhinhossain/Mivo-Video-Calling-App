import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/material.dart';

enum SnackbarType {success, error}

class MyButton extends StatelessWidget {
  final VoidCallback? onTab;
  final String buttonText;
  const MyButton({super.key, required this.onTab, required this.buttonText});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      elevation: 0,
      color: const Color(0xFF3F7AF0),
      disabledColor: Colors.grey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      onPressed: onTab,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Center(
          child: Text(
            buttonText,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

void showAppSnackbar({
  required BuildContext context,
  required SnackbarType type,
  required String description,
}){
  switch(type){
    case SnackbarType.success:
    CherryToast.success(
      toastDuration: Duration(milliseconds: 2500),
      height: 70,
      toastPosition: .top,
      shadowColor: Colors.white,

      animationType: AnimationType.fromTop,
      displayCloseButton: false,
      backgroundColor: Colors.green.withAlpha(40),
      description: Text(
        description,
        style: const TextStyle(color: Colors.green),
      ),
      title: const Text(
        "Successful",
        style: TextStyle(color: Colors.green, fontWeight: .bold),
      ),
    ).show(context);
    break;

    case SnackbarType.error:
      CherryToast.error(
        toastDuration: Duration(milliseconds: 2500),
        height: 70,
        toastPosition: .top,
        shadowColor: Colors.white,

        animationType: AnimationType.fromTop,
        displayCloseButton: false,
        backgroundColor: Colors.red.withAlpha(40),
        description: Text(
          description,
          style: const TextStyle(color: Colors.red),
        ),
        title: const Text(
          "Fail",
          style: TextStyle(color: Colors.red, fontWeight: .bold),
        ),
      ).show(context);
      break;
  }
}