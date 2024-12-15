import 'dart:async';
import 'dart:convert';
import 'package:app/provider/request.dart';
import 'package:background_location/background_location.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io'; // For detecting mobile platforms

class Hospital {
  final String name;
  final String address;
  final String district;
  final String state;
  final String postcode;
  final String phone;
  final Map<String, double> location;

  Hospital({
    required this.name,
    required this.address,
    required this.district,
    required this.state,
    required this.postcode,
    required this.phone,
    required this.location,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      name: json['name'],
      address: json['address'] ?? 'Address not available',
      district: json['district'] ?? 'Unknown District',
      state: json['state'] ?? 'Unknown State',
      postcode: json['postcode'] ?? 'Unknown Postcode',
      phone: json['phone'] ?? 'No Phone Number',
      location: Map<String, double>.from(json['location']),
    );
  }
}

class HospitalRecommendationsPage extends StatefulWidget {
  static Route<HospitalRecommendationsPage> route() {
    return MaterialPageRoute(
        builder: (context) => const HospitalRecommendationsPage());
  }

  const HospitalRecommendationsPage({Key? key}) : super(key: key);

  @override
  _HospitalRecommendationsPageState createState() =>
      _HospitalRecommendationsPageState();
}

class _HospitalRecommendationsPageState
    extends State<HospitalRecommendationsPage> {
  late List<Hospital> hospitals = [];
  Hospital? selectedHospital;

  @override
  void initState() {
    super.initState();
    _loadHospitals().then((loadedHospitals) {
      setState(() {
        hospitals = loadedHospitals;
      });
    });
  }

  Future<void> openGoogleMap(
      {required double latitude, required double longitude}) async {
    final String googleMapUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

    // Check if the platform is Android or iOS
    if (Platform.isAndroid || Platform.isIOS) {
      // Use native URL launching
      Process.run('xdg-open', [googleMapUrl]);
    }
  }

  Future<List<Hospital>> _loadHospitals() async {
    print("Loading hospitals");
    try {
      // Start location service
      BackgroundLocation.startLocationService(distanceFilter: 10);

      // Retrieve location
      Completer<Map<String, double>> locationCompleter = Completer();
      await BackgroundLocation.getLocationUpdates((location) {
        if (!locationCompleter.isCompleted) {
          locationCompleter.complete({
            'latitude': location.latitude!,
            'longitude': location.longitude!,
          });
          BackgroundLocation
              .stopLocationService(); // Stop updates after first fetch
        }
      });

      final location = await locationCompleter.future;
      double latitude = location['latitude']!;
      double longitude = location['longitude']!;

      print("Latitude: $latitude");
      print("Longitude: $longitude");

      // Make API call
      final String? url = dotenv.env["URL"];
      if (url == null) {
        throw Exception("API URL not found in .env file");
      }
      final response = await Dio().get(
        '$url/hospital/nearby-hospitals?lat=$latitude&lon=$longitude',
      );
      print(response.data);

      List<dynamic> jsonList = response.data;
      return jsonList.map((json) => Hospital.fromJson(json)).toList();
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hospital Recommendations'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: hospitals.length,
              itemBuilder: (context, index) {
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text(hospitals[index].name),
                    subtitle: Text(
                      hospitals[index].address != 'Address not available'
                          ? hospitals[index].address
                          : '${hospitals[index].district}, ${hospitals[index].state}',
                    ),
                    onTap: () {
                      setState(() {
                        selectedHospital = hospitals[index];
                      });
                      _showHospitalDetails(context);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showHospitalDetails(BuildContext context) {
    if (selectedHospital == null) return; // Prevent null access

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, controller) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: ListView(
                controller: controller,
                children: [
                  Text(
                    selectedHospital!.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Address', selectedHospital!.address),
                  _buildInfoRow('District', selectedHospital!.district),
                  _buildInfoRow('State', selectedHospital!.state),
                  _buildInfoRow('Postcode', selectedHospital!.postcode),
                  _buildInfoRow('Phone', selectedHospital!.phone),
                  const SizedBox(height: 16),
                  Text(
                    'Location',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  _buildInfoRow(
                      'Latitude', selectedHospital!.location['lat'].toString()),
                  _buildInfoRow('Longitude',
                      selectedHospital!.location['lon'].toString()),
                  TextButton(
                      onPressed: () {
                        openGoogleMap(
                            latitude:
                                selectedHospital!.location['lat'] as double,
                            longitude:
                                selectedHospital!.location['lon'] as double);
                      },
                      child: Text("View"))
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(MaterialApp(home: HospitalRecommendationsPage()));
}
