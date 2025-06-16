import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<Map<String, String>?> login(String mobile, String password) async {
    mobile = "7904421665";
    password = "7904421665";

    var body = {
      "mobileNo": mobile,
      "password": password,
      "userGroup": "warehouse",
      "client": "web"
    };


final response = await http.post(
      Uri.parse(
        'https://business.city-link.co.in/testingstorage/auth/signin'),
      headers: {
        'Content-Type': 'application/json'
      },
      body: jsonEncode(body),
    );

 

    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);


    if (!jsonResponse.containsKey('token')) {
      return null;
    }

    String? token = jsonResponse['token'];
    if (token == null) {
      return null;
    }

    Map<String, dynamic> decodedToken = Jwt.parseJwt(token);

    String? warehouseId;
    if (decodedToken.containsKey('warehouses') &&
        decodedToken['warehouses'] is List &&
        decodedToken['warehouses'].isNotEmpty) {
      warehouseId = decodedToken['warehouses'][0]['id'].toString();
    } else {
      return null;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('token', token);
    prefs.setString('warehouseId', warehouseId);

    return {'token': token, 'warehouseId': warehouseId};
  }
}
