import 'dart:io';
import 'package:app/features/bmi/screen/bmi_screen.dart';
import 'package:app/features/wallet/screen/wallet_start_screen.dart';
import 'package:app/features/wallet/setlock_screen.dart';
import 'package:app/provider/logout.dart';
import 'package:app/services/ml.dart';
import 'package:app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => const HomeScreen());
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void checklock() async {
    const bool lock = true;
    if (lock == true) {
      Navigator.push(context, WalletStatingScreen.route());
    } else {
      Navigator.push(context, SetLockscreen.route());
    }
  }

  String? name;

  @override
  void initState() {
    super.initState();
    _initializeName(); // Call the asynchronous method
  }

  Future<void> _initializeName() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      name = pref.getString("name");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // bottomNavigationBar: Container(),
        body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                    color: CustomTheme.lightTheme.primaryColor,
                    borderRadius: BorderRadius.circular(25)),
              ),
              IconButton(
                  onPressed: () {
                    Logout.logout(context);
                  },
                  icon: const Icon(
                    Icons.settings,
                    size: 28,
                  ))
            ],
          ),
          const SizedBox(
            height: 30,
          ),
          SizedBox(
            width: double.maxFinite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Good morning,",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
                ),
                Text(
                  name ?? 'Guest',
                  style: const TextStyle(
                      fontSize: 32, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const EyeTestingSection(),
          Expanded(
            child: GridView.count(
              crossAxisSpacing: 5,
              mainAxisSpacing: 2,
              crossAxisCount: 3,
              children: <Widget>[
                SelectButton(
                  color: Colors.red,
                  text: "Wallet",
                  icon: Icons.wallet,
                  onPressed: () {
                    checklock();
                  },
                ),
                SelectButton(
                    onPressed: () {
                      Navigator.push(context, BMICalculatorScreen.route());
                    },
                    text: "BMI",
                    color: Colors.teal,
                    icon: Icons.calculate)
              ],
            ),
          )
        ],
      ),
    ));
  }
}

class SelectButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color color;
  final IconData icon;
  const SelectButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        // boxShadow: ,
        borderRadius: BorderRadius.circular(20),
        color: color,
      ),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent),
          onPressed: onPressed,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 64,
              ),
              Text(text),
            ],
          )),
    );
  }
}

class EyeTestingSection extends StatefulWidget {
  const EyeTestingSection({
    super.key,
  });

  @override
  State<EyeTestingSection> createState() => _EyeTestingSectionState();
}

class _EyeTestingSectionState extends State<EyeTestingSection> {
  final MLService _mlService = MLService();

  File? _image;

  String? _prediction;

  @override
  void initState() {
    super.initState();
    _mlService.loadModel();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      final prediction = await _mlService.predict(_image!);
      setState(() {
        _prediction = prediction;
      });
      _dialogBuilder(context, prediction!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      height: 200,
      child: Stack(
        children: [
          Positioned(
              child: Container(
            width: double.maxFinite,
            height: 150,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.blue[50]),
          )),
          const Positioned(
              right: 10,
              bottom: 50,
              width: 250,
              child: Image(image: AssetImage("assets/oculist.png"))),
          Positioned(
              bottom: 10,
              left: 30,
              child: Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color:
                            const Color.fromARGB(81, 0, 0, 0).withOpacity(0.36),
                        offset: const Offset(3, 4),
                        blurRadius: 6,
                        spreadRadius: -1,
                      ),
                    ],
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(25))),
                child: IconButton(
                    color: Colors.black,
                    onPressed: pickImage,
                    icon: const Icon(Icons.navigate_next_outlined)),
              )),
        ],
      ),
    );
  }

  Future<void> _dialogBuilder(BuildContext context, String content) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Basic dialog title'),
          content: Text(
            content,
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Disable'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Enable'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
