import 'package:flutter/material.dart';

// ignore: must_be_immutable
class AuthInputField extends StatefulWidget {
  final TextEditingController textController;
  final String? labelText;
  final String? hintText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  bool obscureText;
  final bool password;

  AuthInputField(
      {super.key,
      required this.textController,
      this.labelText,
      this.hintText,
      this.keyboardType = TextInputType.text,
      this.validator,
      this.obscureText = false,
      this.password = false});

  @override
  State<AuthInputField> createState() => _AuthInputFieldState();
}

bool changeicon = true;

class _AuthInputFieldState extends State<AuthInputField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.textController,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      decoration: InputDecoration(
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
                  icon: Icon(
                      changeicon ? Icons.visibility : Icons.visibility_off),
                )
              : null,
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red)),
          focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red)),
          focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.blue),
              borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );
  }
}
