import 'package:app/features/auth/provider/auth_serializer.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

final String? url = dotenv.env["URL"];

class AuthProiver {
  final dio = Dio();
  Future<String?> loginFun(String email, String password) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    Response response;

    try {
      response = await dio.post('$url/auth/login',
          data: {"email": email, "password": password});

      Auth authdata = Auth.fromJson(response.data);
      if (authdata.user != null) {
        await pref.setString("token", authdata.user!.sessionToken!);
        await pref.setString("name", authdata.user!.name!);
        await pref.setInt("id", authdata.user!.id!);
      }
      return authdata.message;
    } catch (e) {
      return "Error in login!";
    }
  }

  Future<String?> signupFun(String name, String email, String password) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    Response response;
    try {
      response = await dio.post('$url/auth/signup',
          data: {"name": name, "email": email, "password": password});

      Auth authdata = Auth.fromJson(response.data);
      if (authdata.user != null) {
        await pref.setString("token", authdata.user!.sessionToken!);
        await pref.setInt("id", authdata.user!.id!);
        await pref.setString("name", authdata.user!.name!);
      }

      return authdata.message;
    } catch (e) {
      return "Error in signup!";
    }
  }
}
