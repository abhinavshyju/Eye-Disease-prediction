import 'package:app/features/auth/components/auth_input_field.dart';
import 'package:app/features/auth/provider/auth.dart';
import 'package:app/features/auth/screen/signup_screen.dart';
import 'package:app/features/home/screen/home_screen.dart';
import 'package:app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      );
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Not validate';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Not validate';
    }
    return null;
  }

  void _signin() async {
    if (_formKey.currentState!.validate()) {
      print("Validated");
      final auth = AuthProiver();
      final res = await auth.loginFun(_username.text, _password.text);
      print(res);
      if (res == "User logged in") {
        // ignore: use_build_context_synchronously
        Navigator.push(context, HomeScreen.route());
      }
      if (res == "User not found") {
        Fluttertoast.showToast(
            msg: "User not found",
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.transparent,
            textColor: Colors.red);
      }
      if (res == "Invalid password") {
        Fluttertoast.showToast(
            msg: "Invalid password",
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.transparent,
            textColor: Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Let's sign you in.",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Welcome back.",
                  style: TextStyle(fontSize: 29, fontWeight: FontWeight.w600),
                ),
                Text(
                  "You’ve been missed!",
                  style: TextStyle(fontSize: 29, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          Form(
              key: _formKey,
              child: Column(
                children: [
                  // Username input
                  AuthInputField(
                    textController: _username,
                    validator: _validateUsername,
                    hintText: "Username or Email",
                  ),
                  const SizedBox(height: 20),
                  AuthInputField(
                    textController: _password,
                    hintText: "Password",
                    obscureText: true,
                    validator: _validatePassword,
                    keyboardType: TextInputType.visiblePassword,
                    password: true,
                  )
                ],
              )),
          const SizedBox(height: 20),
          // Container(
          //   alignment: Alignment.centerRight,
          //   child: const Text("Recovery password?"),
          // ),
          const SizedBox(height: 20),
          button(() {
            _signin();
          }, "Sign in"),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Text("Not an account yet?"),
            TextButton(
              onPressed: () {
                Navigator.push(context, SignupScreen.route());
              },
              child: Text("Sign up"),
              style: TextButton.styleFrom(backgroundColor: Colors.transparent),
            )
          ])
        ],
      ),
    ));
  }
}

ElevatedButton button(onPress, hint) {
  return ElevatedButton(
    onPressed: onPress != null ? onPress as void Function()? : null,
    style: ElevatedButton.styleFrom(
        disabledBackgroundColor: LightColor.primary_dienabled,
        backgroundColor: LightColor.primary,
        shadowColor: LightColor.transperant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
    child: Container(
      width: double.infinity,
      height: 50,
      alignment: Alignment.center,
      child: Text(
        style: const TextStyle(fontSize: 18, color: Colors.white),
        hint,
      ),
    ),
  );
}
