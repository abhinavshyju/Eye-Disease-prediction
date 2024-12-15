import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

class DoctorSearch extends StatefulWidget {
  const DoctorSearch({super.key});

  @override
  State<DoctorSearch> createState() => _DoctorSearchState();
}

class _DoctorSearchState extends State<DoctorSearch> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _degreeController = TextEditingController();
  final TextEditingController _specializationController =
      TextEditingController();
  List<dynamic> _doctors = [];
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onSearchChanged);
    _degreeController.addListener(_onSearchChanged);
    _specializationController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchDoctors();
    });
  }

  Future<void> _searchDoctors() async {
    setState(() => _isLoading = true);
    try {
      final url = dotenv.env['URL'];
      final response = await http.get(
        Uri.parse(
            '$url/hospital/doctors?name=${_nameController.text}&degree=${_degreeController.text}&specialization=${_specializationController.text}'),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success']) {
          setState(() {
            _doctors = responseData['data'];
          });
        } else {
          throw Exception(responseData['error'] ?? 'Unknown error occurred');
        }
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error searching doctors')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Doctors'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Doctor Name',
                hintText: 'Enter doctor name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _degreeController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Degree',
                hintText: 'Enter degree (MBBS, MD, etc.)',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _specializationController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Specialization',
                hintText: 'Enter specialization',
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _doctors.length,
                      itemBuilder: (context, index) {
                        final doctor = _doctors[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doctor['name'] ?? 'N/A',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                  Icons.email,
                                  'Email:',
                                  doctor['email'] ?? 'N/A',
                                ),
                                _buildInfoRow(
                                  Icons.phone,
                                  'Phone:',
                                  doctor['phone'] ?? 'N/A',
                                ),
                                _buildInfoRow(
                                  Icons.school,
                                  'Degree:',
                                  doctor['degree'] ?? 'N/A',
                                ),
                                _buildInfoRow(
                                  Icons.medical_services,
                                  'Specialization:',
                                  doctor['specialization'] ?? 'N/A',
                                ),
                                _buildInfoRow(
                                  Icons.local_hospital,
                                  'Working Hospital:',
                                  doctor['working_hospital'] ?? 'N/A',
                                ),
                                _buildInfoRow(
                                  Icons.local_hospital,
                                  'Working address:',
                                  doctor['working_address'] ?? 'N/A',
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _nameController.removeListener(_onSearchChanged);
    _degreeController.removeListener(_onSearchChanged);
    _nameController.dispose();
    _degreeController.dispose();
    super.dispose();
  }
}
