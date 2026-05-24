import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://bible-api-nine.vercel.app";
  static Future<List<dynamic>> getAudios() async {
    final res = await http.get(Uri.parse("$baseUrl/audios"));
    if (res.statusCode == 200) return json.decode(res.body);
    throw Exception("Falha ao carregar áudios");
  }
}