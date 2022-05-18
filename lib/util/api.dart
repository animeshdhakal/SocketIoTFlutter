import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class Api {
  static const String baseUrl = "https://unhpu.com.np";
  static const String ws = "wss://unhpu.com.np/appws";

  String? accessToken;
  String? refreshToken;
  int? expiresIn;

  Future<http.Response> wpost(String uri, {Object? body}) {
    return http.post(Uri.parse(baseUrl + uri), body: jsonEncode(body));
  }

  Future refreshAccessToken() async {
    final response = await wpost("/api/user/refresh", body: {
      "refresh_token": refreshToken,
    });
    final data = jsonDecode(response.body);
    accessToken = data["access_token"];
    expiresIn = data["expires_in"] + DateTime.now().millisecondsSinceEpoch;
  }

  Future<http.Response> post(String uri, {Object? body}) async {
    if (expiresIn! < DateTime.now().millisecondsSinceEpoch) {
      await refreshAccessToken();
    }

    http.Response response = await http.post(
      Uri.parse(baseUrl + uri),
      body: jsonEncode(body),
      headers: {
        "Authorization": "Bearer $accessToken",
      },
    );

    return response;
  }
}

final api = Api();
