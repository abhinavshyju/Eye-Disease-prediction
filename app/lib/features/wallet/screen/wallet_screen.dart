import 'package:app/features/wallet/screen/image_upload.dart';
import 'package:app/features/wallet/screen/preview_screen.dart';
import 'package:app/provider/request.dart';
import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  static route() =>
      MaterialPageRoute(builder: (context) => const WalletScreen());

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    getData();
  }

  List<Map<String, dynamic>> prescriptionData = [];

  void getData() async {
    final res = await Request.get(path: "/user/getdoc");
    if (res != null && res.data is List) {
      // Cast and assign the data to prescriptionData
      setState(() {
        prescriptionData = List<Map<String, dynamic>>.from(
            res.data.map((item) => Map<String, dynamic>.from(item)));
      });
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wallet"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const ImageUploadForm()));
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 items per row
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: prescriptionData.length,
          itemBuilder: (BuildContext context, int index) {
            final item = prescriptionData[index];
            return ImageContainer(
              title: item['title'],
              onPressed: () {
                Navigator.push(context, PreviewScreen.route(index));
              },
              imageUrl:
                  "${dotenv.env["URL"]}/user/doc/${item['url']}", // Use image URL from API response
            );
          },
        ),
      ),
    );
  }
}

class ImageContainer extends StatelessWidget {
  final VoidCallback onPressed;
  final String imageUrl;
  final String title;

  const ImageContainer({
    super.key,
    required this.onPressed,
    required this.imageUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero, // Remove default padding
        backgroundColor: Colors.transparent, // Transparent background
      ),
      onPressed: onPressed,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align items to the start
        children: [
          Expanded(
            // Wrap the image in Expanded to take up available space
            child: Container(
              padding:
                  const EdgeInsets.all(8), // Add some padding around the image
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover, // Make sure the image scales to fit
                  width: double.infinity, // Make the image fill its container
                ),
              ),
            ),
          ),
          const SizedBox(height: 8), // Add space between image and title
          Flexible(
            // Use Flexible to prevent overflow of long text
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1, // Limit the text to one line
              overflow:
                  TextOverflow.ellipsis, // Add ellipsis if text is too long
            ),
          ),
        ],
      ),
    );
  }
}
