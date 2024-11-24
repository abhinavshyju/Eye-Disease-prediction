import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Request {
  static Future<Response?> post({Object? object, required String path}) async {
    final dio = Dio();
    final SharedPreferences pref = await SharedPreferences.getInstance();

    try {
      final token = pref.getString("token");

      final data = {"data": object, "token": token};
      final String? url = dotenv.env["URL"];
      final response = await dio.post('$url$path', data: data);

      return response;
    } catch (e) {
      print('Error in post request: $e');
      return null;
    }
  }

  static Future<Response?> get({required String path}) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    final dio = Dio();
    try {
      final token = pref.getString("token");
      final String? url = dotenv.env["URL"];
      final response = await dio.get('$url$path/$token');

      return response;
    } catch (e) {
      print('Error in GET request: $e');
      return null;
    }
  }
}
