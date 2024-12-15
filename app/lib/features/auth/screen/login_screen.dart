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
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  void _signin() async {
    if (_formKey.currentState!.validate()) {
      try {
        final auth = AuthProiver();
        final res = await auth.loginFun(_username.text, _password.text);
        if (res == "User logged in") {
          Navigator.pushReplacement(context, HomeScreen.route());
        } else if (res == "User not found") {
          Fluttertoast.showToast(
              msg: "User not found",
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.black,
              textColor: Colors.red);
        } else if (res == "Invalid password") {
          Fluttertoast.showToast(
              msg: "Invalid password",
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.black,
              textColor: Colors.red);
        } else {
          Fluttertoast.showToast(
              msg: "Login failed. Please try again.",
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.black,
              textColor: Colors.red);
        }
      } catch (e) {
        Fluttertoast.showToast(
            msg: "An error occurred: \$e",
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black,
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
                    hintText: "Email",
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
          ElevatedButton(
            onPressed: _signin,
            style: ElevatedButton.styleFrom(
                disabledBackgroundColor: LightColor.primary_dienabled,
                backgroundColor: LightColor.primary,
                shadowColor: LightColor.transperant,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: Container(
              width: double.infinity,
              height: 50,
              alignment: Alignment.center,
              child: const Text(
                style: TextStyle(fontSize: 18, color: Colors.white),
                "Sign in",
              ),
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            const Text("Not an account yet?"),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(context, SignupScreen.route());
              },
              child: const Text("Sign up"),
              style: TextButton.styleFrom(backgroundColor: Colors.transparent),
            )
          ])
        ],
      ),
    ));
  }
}
