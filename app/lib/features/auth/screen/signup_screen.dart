import 'package:app/features/auth/components/auth_input_field.dart';
import 'package:app/features/auth/provider/auth.dart';
import 'package:app/features/auth/screen/login_screen.dart';
import 'package:app/features/home/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupScreen extends StatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const SignupScreen(),
      );
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tokenCheck();
  }

  void tokenCheck() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    final token = pref.getString("token");
    if (token != null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    }
  }

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      final auth = AuthProiver();
      final res =
          await auth.signupFun(_name.text, _username.text, _password.text);
      if (res == "User already exsist") {
        Fluttertoast.showToast(
            msg: "User already exsist",
            backgroundColor: Colors.transparent,
            textColor: Colors.red);
      }
      if (res == "New user created") {
        Navigator.push(context, HomeScreen.route());
      } else {
        Fluttertoast.showToast(
            msg: "SignUp failed",
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
                  "Let's sign you up.",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Welcome !",
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
                  AuthInputField(
                    textController: _name,
                    validator: _validateName,
                    hintText: "Name",
                  ),
                  const SizedBox(height: 20),
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
            _signUp();
          }, "Sign Up"),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text("Already have an account ?"),
              TextButton(
                onPressed: () {
                  Navigator.push(context, LoginScreen.route());
                },
                child: Text("Sign in"),
                style:
                    TextButton.styleFrom(backgroundColor: Colors.transparent),
              )
            ],
          )
        ],
      ),
    ));
  }
}
