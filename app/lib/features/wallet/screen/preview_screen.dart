import 'package:app/provider/request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_markdown/flutter_markdown.dart'; // Import flutter_markdown

class PreviewScreen extends StatefulWidget {
  final int index;

  static route(int index) => MaterialPageRoute(
      builder: (context) => PreviewScreen(index: index)); // Fix typo in name

  const PreviewScreen({super.key, required this.index});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  Map<String, dynamic> prescriptionData = {};
  bool isLoading = true; // Add a loading state

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    final res = await Request.get(path: "/user/getdocin/${widget.index}");
    if (res != null && res.data != null) {
      setState(() {
        prescriptionData = res.data; // Assuming res.data is a map
        isLoading = false; // Stop loading
      });
    } else {
      setState(() {
        isLoading = false; // Stop loading even on failure
      });
      print("Failed to fetch data or invalid response format");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Preview Screen"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: isLoading
            ? Center(child: CircularProgressIndicator()) // Show loading spinner
            : prescriptionData.isEmpty
                ? Center(
                    child: Text(
                      "Failed to load prescription data.",
                      style: TextStyle(fontSize: 18, color: Colors.red),
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display the image from the API response if available
                        prescriptionData.containsKey('url') &&
                                prescriptionData['url'] != null
                            ? Image.network(
                                "${"https://eye-disease-prediction-1.onrender.com"}/user/doc/${prescriptionData['url']}",
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                'assets/oculist.png'), // Fallback image
                        const SizedBox(height: 20),
                        prescriptionData.containsKey('title') &&
                                prescriptionData['title'] != null
                            ? Text(
                                prescriptionData['title'],
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              )
                            : Text("No Title Available",
                                style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 20),

                        // Display the Markdown data
                        prescriptionData.containsKey('data') &&
                                prescriptionData['data'] != null
                            ? MarkdownBody(
                                data: prescriptionData['data'],
                                styleSheet: MarkdownStyleSheet(
                                  h1: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                  p: const TextStyle(fontSize: 16),
                                ),
                              )
                            : Text("No Data Available",
                                style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
      ),
    );
  }
}
