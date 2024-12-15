import 'dart:io';
import 'package:app/features/bmi/screen/bmi_screen.dart';
import 'package:app/features/hospital/doctor_search.dart';
import 'package:app/features/hospital/hospital_recomentation.dart';
import 'package:app/features/record.dart';
import 'package:app/features/wallet/screen/wallet_start_screen.dart';
import 'package:app/features/wallet/setlock_screen.dart';
import 'package:app/provider/logout.dart';
import 'package:app/provider/request.dart';
import 'package:app/services/ml.dart';
import 'package:app/utils/theme.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    _initializeName();
  }

  Future<void> _initializeName() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      name = pref.getString("name");
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
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
                child: Icon(Icons.account_circle_rounded, size: 45),
                decoration: BoxDecoration(
                    color: CustomTheme.lightTheme.focusColor,
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
                Text(
                  "${_getGreeting()},",
                  style: const TextStyle(
                      fontSize: 32, fontWeight: FontWeight.w600),
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
              mainAxisSpacing: 5,
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
                    icon: Icons.calculate),
                SelectButton(
                    onPressed: () {
                      Navigator.push(context, MedicalRecordsPage.route());
                    },
                    text: "Records",
                    color: Colors.blue,
                    icon: Icons.receipt_long_rounded),
                SelectButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const DoctorSearch()));
                    },
                    text: "Doctors",
                    color: Colors.yellow,
                    icon: Icons.medical_services),
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

  List<File> _images = [];

  String? _prediction;

  @override
  void initState() {
    super.initState();
    _mlService.loadModel();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    _images.clear(); // Clear previous images

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(child: CircularProgressIndicator());
      },
    );

    // Pick 5 images
    for (int i = 0; i < 5; i++) {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _images.add(File(pickedFile.path));
      } else {
        Navigator.of(context).pop(); // Close loading indicator
        return;
      }
    }

    // Process all images and get predictions
    List<String> predictions = [];
    for (File image in _images) {
      final prediction = await _mlService.predict(image);
      if (prediction != null) {
        predictions.add(prediction);
      }
    }

    Future<int> _checkEye() async {
      final String? url = dotenv.env["URL"];
      final SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");
      FormData formData = FormData.fromMap({
        'token': token,
        'image': await MultipartFile.fromFile(_images[0].path,
            filename: _images[0].path.split('/').last),
      });
      print("$url/eye");
      try {
        final response = await Dio().post(
          "$url/eye",
          data: formData,
          options: Options(contentType: 'multipart/form-data'),
        );
        if (response.data['message'] == "Eyes detected") {
          return 1;
        } else {
          return 0;
        }
      } catch (e) {
        print(e);
        return 0;
      }
    }

    // Get the most common prediction
    final mostCommonPrediction = _getMostCommonPrediction(predictions);

    // Close loading indicator
    Navigator.of(context).pop();

    if (mostCommonPrediction != null) {
      setState(() {
        _prediction = mostCommonPrediction;
      });
      final check = await _checkEye();
      if (check == 1) {
        _dialogBuilder(context, 'Predicted disease: $mostCommonPrediction\n\n');
      } else {
        _dialogBuilder(context, 'No eyes detected');
      }
    }
  }

  Future<void> sendRequest(String result) async {
    await Request.post(path: "/user/eye", object: {"result": result});
  }

  String? _getMostCommonPrediction(List<String> predictions) {
    if (predictions.isEmpty) return null;

    // Count occurrences of each prediction
    Map<String, int> counts = {};
    for (String prediction in predictions) {
      counts[prediction] = (counts[prediction] ?? 0) + 1;
    }

    // Find the prediction with maximum count
    String? mostCommon;
    int maxCount = 0;
    counts.forEach((prediction, count) {
      if (count > maxCount) {
        maxCount = count;
        mostCommon = prediction;
      }
    });
    sendRequest(mostCommon!);
    return mostCommon;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: double.maxFinite,
          height: 200,
          child: Stack(
            children: [
              Positioned(
                  child: Container(
                width: double.maxFinite,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue[100]!, Colors.blue[50]!],
                  ),
                ),
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
                    width: 160,
                    height: 50,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          offset: const Offset(0, 4),
                          blurRadius: 8,
                        ),
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextButton.icon(
                        onPressed: () async {
                          await mlDialogBuilder(context);
                        },
                        icon: const Icon(Icons.remove_red_eye,
                            color: Colors.blue),
                        label: const Text(
                          "Test your eye",
                          style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600),
                        ),
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        )),
                  )),
            ],
          ),
        )
      ],
    );
  }

  Future<void> _dialogBuilder(BuildContext context, String content) {
    // Extract the condition from the content string
    final condition = content.split(':').last.trim();

    // Get recommendations based on the condition
    String recommendations = _getRecommendations(condition);

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Result'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(content),
                const SizedBox(height: 16),
                const Text(
                  'Recommendations:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(recommendations),
                const SizedBox(height: 16),
                const Text(
                  'Important: This is not a medical diagnosis. Please consult an eye care professional for proper medical advice.',
                  style: TextStyle(
                    color: Colors.red,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Hospital recommendations'),
              onPressed: () {
                Navigator.push(context, HospitalRecommendationsPage.route());
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String _getRecommendations(String condition) {
    switch (condition) {
      case 'Cataract':
        return '''
• Schedule an appointment with an ophthalmologist
• Protect your eyes from UV radiation with sunglasses
• Maintain good lighting when reading
• Consider surgery if recommended by your doctor
• Regular eye check-ups
• Quit smoking if applicable
• Maintain a healthy diet rich in antioxidants''';

      case 'Conjunctivitis':
        return '''
• Avoid touching or rubbing your eyes
• Use a clean, warm compress on eyes
• Artificial tears may provide relief
• Practice good hand hygiene
• Avoid sharing personal items
• See a doctor if symptoms persist
• Use prescribed eye drops if recommended''';

      case 'Glaucoma':
        return '''
• Immediate consultation with an eye specialist
• Regular eye pressure monitoring
• Take prescribed medications consistently
• Regular exercise (but avoid head-down positions)
• Protect eyes during sports
• Regular eye examinations
• Family members should also get checked
• Maintain a healthy blood pressure''';

      case 'Normal':
        return '''
• Continue regular eye check-ups
• Protect eyes from UV radiation
• Take regular screen breaks (20-20-20 rule)
• Maintain good eye hygiene
• Eat a balanced diet rich in vitamins A and C
• Stay hydrated
• Get adequate sleep''';

      default:
        return 'Eyes not detected please try again';
    }
  }

  Future<void> mlDialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Note'),
          content: Text(
            "Use a clear image of your eye for better results, and try to take the image in a well lit environment, and use 5 images for better results",
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Ok'),
              onPressed: () {
                pickImage();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
