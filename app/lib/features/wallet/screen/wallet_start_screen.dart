import 'package:app/features/home/screen/home_screen.dart';
import 'package:app/features/wallet/screen/wallet_screen.dart';
import 'package:app/features/wallet/setlock_screen.dart';
import 'package:app/provider/request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';

class WalletStatingScreen extends StatefulWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => const WalletStatingScreen());
  const WalletStatingScreen({super.key});

  @override
  State<WalletStatingScreen> createState() => _WalletStatingScreenState();
}

class _WalletStatingScreenState extends State<WalletStatingScreen> {
  @override
  void initState() {
    super.initState();
    _check_pass();
  }

  void navigate() async {
    Navigator.pushReplacement(context, WalletScreen.route());
  }

  void _check_pass() async {
    final res = await Request.get(path: "/auth/getpass");
    if (res?.data["message"] != "Password not found") {
      final passwordString = res?.data["message"];
      screenLock(
        context: context,
        onCancelled: () {
          Navigator.push(context, HomeScreen.route());
        },
        correctString: "$passwordString",
        onUnlocked: () {
          navigate();
        },
      );
    } else {
      Navigator.push(context, SetLockscreen.route());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
