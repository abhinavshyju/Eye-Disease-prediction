import 'dart:convert';

import 'package:app/provider/request.dart';
import 'package:flutter/material.dart';

class MedicalRecord {
  final String type;
  final String date;
  final dynamic result;
  final double? height;
  final double? weight;

  MedicalRecord({
    required this.type,
    required this.date,
    required this.result,
    this.height,
    this.weight,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    // Validate and sanitize input
    String type = json['type'] ?? '';
    String date = json['date'] ?? '';
    dynamic result = json['result'];
    double? height = (json['height'] != null && json['height'] is num)
        ? (json['height'] as num).toDouble()
        : null;
    double? weight = (json['weight'] != null && json['weight'] is num)
        ? (json['weight'] as num).toDouble()
        : null;

    // Handle unexpected BMI results
    if (type == 'bmi' && (height == null || weight == null)) {
      throw Exception('Invalid BMI data: height or weight is missing');
    }

    return MedicalRecord(
      type: type,
      date: date,
      result: result,
      height: height,
      weight: weight,
    );
  }
}

class MedicalRecordsPage extends StatefulWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => const MedicalRecordsPage());
  const MedicalRecordsPage({Key? key}) : super(key: key);

  @override
  _MedicalRecordsPageState createState() => _MedicalRecordsPageState();
}

class _MedicalRecordsPageState extends State<MedicalRecordsPage> {
  TextEditingController _searchController = TextEditingController();
  List<MedicalRecord> _allRecords = [];
  List<MedicalRecord> _filteredRecords = [];

  @override
  void initState() {
    super.initState();
    _fetchMedicalRecords();
  }

  Future<void> _fetchMedicalRecords() async {
    try {
      final response = await Request.get(path: '/user/getresult');
      if (response != null && response.statusCode == 200) {
        String rawData = response.data.toString();

        // Fix malformed JSON by adding quotes around keys and string values
        String fixedJson = rawData
            .replaceAllMapped(RegExp(r'(\w+):'),
                (match) => '"${match.group(1)}":') // Wrap keys in quotes
            .replaceAllMapped(RegExp(r':\s*([\w\-/\.]+)(,|\})'), (match) {
          final value = match.group(1)!;
          // Check if the value is numeric or already a string
          if (double.tryParse(value) != null || value == 'null') {
            return ': $value${match.group(2)}'; // Keep numeric or null values as is
          } else {
            return ': "$value"${match.group(2)}'; // Wrap other values in quotes
          }
        });

        // Decode the fixed JSON
        final List<dynamic> jsonData = json.decode(fixedJson);

        // Convert to list of MedicalRecord objects
        _allRecords = jsonData
            .map((json) => MedicalRecord.fromJson(json as Map<String, dynamic>))
            .toList();

        // Initially set filtered records to all records
        setState(() {
          _filteredRecords = List.from(_allRecords);
        });
      } else {
        throw Exception(
            'Failed to load medical records. Status code: ${response?.statusCode}');
      }
    } catch (error) {
      throw Exception('An error occurred: $error');
    }
  }

  // Search filter method
  void _filterRecords(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredRecords = List.from(_allRecords);
      });
    } else {
      setState(() {
        _filteredRecords = _allRecords.where((record) {
          return record.type.toLowerCase().contains(query.toLowerCase()) ||
              record.date.contains(query) ||
              record.result.toString().contains(query);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Records'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Records',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (query) => _filterRecords(query),
            ),
          ),
          Expanded(
            child: _filteredRecords.isEmpty
                ? const Center(child: Text('No records found'))
                : ListView.builder(
                    itemCount: _filteredRecords.length,
                    itemBuilder: (context, index) {
                      final record = _filteredRecords[index];
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                record.type.toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text('Date: ${record.date}'),
                              const SizedBox(height: 8),
                              if (record.type == 'bmi') ...[
                                Text(
                                    'Height: ${record.height?.toStringAsFixed(2)} m'),
                                Text(
                                    'Weight: ${record.weight?.toStringAsFixed(2)} kg'),
                                Text('BMI: ${record.result}'),
                              ] else if (record.type == 'eye') ...[
                                Text('Result: ${record.result}'),
                              ] else ...[
                                Text('Details: ${record.result}'),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
