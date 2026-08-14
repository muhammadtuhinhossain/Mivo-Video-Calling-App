import 'package:flutter/material.dart';

class NavigationHelper{
  static void push(BuildContext context, Widget screen){
    Navigator.push(context, MaterialPageRoute(builder: (context)=> screen));
  }

  static void pushNamed(BuildContext context, String routeName,{
    Object? arguments,
  }){
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

static void pushReplacement(BuildContext context, Widget screen) {
  Navigator.pushReplacement(
    context, MaterialPageRoute(builder: (context) => screen),
  );
}

static void pop(BuildContext context, {dynamic result}){
    Navigator.pop(context, result);
}

static void pushAndRemoveUntil(BuildContext context, Widget screen){
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> screen), (predicate)=> false);

}

}