import 'package:app/features/wallet/screen/wallet_screen.dart';
import 'package:app/provider/request.dart';
import 'package:flutter/material.dart';

class SetLockscreen extends StatefulWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => const SetLockscreen());

  const SetLockscreen({super.key});

  @override
  State<SetLockscreen> createState() => _SetLockscreenState();
}

class _SetLockscreenState extends State<SetLockscreen> {
  final TextEditingController _password = TextEditingController();
  final TextEditingController _passwordConfirm = TextEditingController();

  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    // _check_pass();
    _password.addListener(_validatePasswords);
    _passwordConfirm.addListener(_validatePasswords);
  }

  // void navigate() async {
  //   Navigator.push(context, WalletScreen.route());
  // }

  // void _check_pass() async {
  //   final res = await Request.get(path: "/auth/getpass");
  //   if (res?.data["message"] != "Password not found") {
  //     final passwordString = res?.data["message"];
  //     screenLock(
  //       context: context,
  //       correctString: "$passwordString",
  //       onUnlocked: () {
  //         navigate();
  //       },
  //     );
  //   }
  // }

  void _validatePasswords() {
    setState(() {
      _isButtonEnabled =
          _password.text.isNotEmpty && _password.text == _passwordConfirm.text;
    });
  }

  @override
  void dispose() {
    _password.dispose();
    _passwordConfirm.dispose();
    super.dispose();
  }

  void setpass() async {
    try {
      final response = await Request.post(
          path: "/auth/setpass", object: {"password": _password.text});
      if (response?.data["password"] != null) {
        Navigator.push(context, WalletScreen.route());
      }
      // print(response?.data["password"]);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 200),
              const Text(
                "Create password",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              PasswordField(
                textController: _password,
                keyboardType: TextInputType.number,
                obscureText: true,
                password: true,
              ),
              const SizedBox(height: 10),
              const Text("Re-enter the password"),
              const SizedBox(height: 10),
              PasswordField(
                textController: _passwordConfirm,
                keyboardType: TextInputType.number,
                obscureText: true,
                password: true,
                textConfirm: _password,
              ),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _isButtonEnabled
                ? () {
                    if (_isButtonEnabled) {
                      setpass();
                    }
                  }
                : null,
            child: Container(
              width: double.maxFinite,
              height: 50,
              alignment: Alignment.center,
              child: const Text(
                "Proceed",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}

// ignore: must_be_immutable
class PasswordField extends StatefulWidget {
  final TextEditingController textController;
  final TextEditingController? textConfirm;
  final String? labelText;
  final String? hintText;
  final TextInputType? keyboardType;
  bool obscureText;
  final bool password;

  PasswordField({
    super.key,
    required this.textController,
    this.textConfirm,
    this.labelText,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.password = false,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool changeicon = false;
  var _text = "";

  String? get _errorText {
    final text = _text;
    if (widget.textConfirm?.value != null) {
      if (widget.textConfirm?.text != text) {
        return "Passwords do not match";
      }
    }

    if (text.isEmpty) {
      return null;
    }
    if (text.length < 4) {
      return "Password is too short";
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.textController,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      onChanged: (value) => {
        setState(() {
          _text = value;
        })
      },
      decoration: InputDecoration(
        errorText: _errorText,
        hintStyle: const TextStyle(
          fontSize: 16,
        ),
        hintText: widget.hintText,
        labelText: widget.labelText,
        suffixIcon: widget.password
            ? IconButton(
                onPressed: () {
                  setState(() {
                    widget.obscureText = !widget.obscureText;
                    changeicon = !changeicon;
                  });
                },
                icon:
                    Icon(changeicon ? Icons.visibility : Icons.visibility_off),
              )
            : null,
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blue),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
